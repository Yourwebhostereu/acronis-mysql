#!/usr/bin/env bash
# Based on Acronis Plesk backup file
# This file sets a lock on the MySQL tables for 10 seconds.

DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$DIR"/capture-data-config.sh

echo "$(date -Ins) - MYSQL USER IS $MYSQL_USER" >> "$LOGFILE"

if [ -z "$MYSQL_USER" ]; then
  echo "$(date -Ins) - MySQL user is empty; checking if ~/.my.cnf exists." >> "$LOGFILE"
  mysql_password="$(cat "$MYSQL_PASSWORD_PATH")"
fi
echo $MYSQL_PASSWORD
if [ -f "$MYSQL_FREEZE_LOCKFILE" ]; then
  if [ -n "$(ps -p "$(/bin/cat "$MYSQL_FREEZE_LOCKFILE")" -o pid=)" ]; then
    echo "Can not start freezing because process already exists" >> "$LOGFILE"
    exit 1
  fi

  echo "$(date -Ins) - Deleting freeze lock file..." >> "$LOGFILE"
  /bin/rm -f "$MYSQL_FREEZE_LOCKFILE"
  if [ -f "$MYSQL_FREEZE_LOCKFILE" ]; then
    echo "$(date -Ins) - Unable to remove "$MYSQL_FREEZE_LOCKFILE"" >> "$LOGFILE"
    exit 1
  fi
fi

flush_tables_sql="FLUSH TABLES; FLUSH TABLES; FLUSH TABLES WITH READ LOCK"
if [ "$MYSQL_FREEZE_ONLY_MYISAM" -eq "1" ]; then
  sql_myisam_tables="SET SESSION group_concat_max_len = 4294967295; \
    SELECT COUNT(*), IFNULL(GROUP_CONCAT(t.db_table SEPARATOR ','), '') as res FROM (SELECT CONCAT('\`', TABLE_SCHEMA, '\`.\`', TABLE_NAME, '\`') as db_table FROM information_schema.TABLES WHERE ENGINE='MyISAM' AND TABLE_SCHEMA NOT IN('mysql','information_schema','performance_schema')) t;"
  sql_output=$(mysql --user="$MYSQL_USER" --password="$mysql_password" --execute="$sql_myisam_tables" | tail -n +2 | awk '{$1=$1;print}')
  read myisam_tables_num myisam_tables < <(echo $sql_output)
  if [ -z "$myisam_tables" ]; then
      echo "$(date -Ins) - There are no MyISAM tables to lock." >> "$LOGFILE"
      return
  fi

  echo "$(date -Ins) - Trying to lock $myisam_tables_num tables." >> "$LOGFILE"

  echo "$(date -Ins) - Starting MySQL freeze session..." >> "$LOGFILE"
  flush_tables_sql="FLUSH TABLES $myisam_tables; FLUSH TABLES $myisam_tables; FLUSH TABLES $myisam_tables WITH READ LOCK"
else
  echo "$(date -Ins) - Trying to lock all tables." >> "$LOGFILE"
fi
freeze_sql="SELECT CONNECTION_ID(); $flush_tables_sql; SYSTEM touch \"$MYSQL_FREEZE_LOCKFILE\"; SYSTEM sleep $MYSQL_FREEZE_SNAPSHOT_TIMEOUT;"
freeze_sql_file="$DIR/freeze_mysql.sql"
echo "$freeze_sql" > "$freeze_sql_file"
mysql --user="$MYSQL_USER" --password="$mysql_password" --unbuffered --silent --skip-column-names < "$freeze_sql_file" 1> "${MYSQL_OUTPUT_FILE}" 2>> "$LOGFILE" &

FREEZE_SESSION_PID=$!
echo "$(date -Ins) - Started MySQL freeze session, PID is $FREEZE_SESSION_PID..." >> "$LOGFILE"

attempts=0
while [ ! -f "$MYSQL_FREEZE_LOCKFILE" ]; do

  if [ -z "$(ps -p $FREEZE_SESSION_PID -o pid=)" ]; then
    echo "$(date -Ins) - Seems like MySQL freeze statement failed. Aborted." >> "$LOGFILE"
    exit 1
  fi

  sleep 1s
  attempts=$((attempts+1))

  if [ $attempts -gt $MYSQL_FREEZE_TIMEOUT ]; then
    echo "$(date -Ins) - MySQL cannot freeze in suitable time. Aborting..." >> "$LOGFILE"

    if kill $FREEZE_SESSION_PID ; then
        echo "$(date -Ins) - $FREEZE_SESSION_PID was killed." >> "$LOGFILE"
    else
        echo "$(date -Ins) - Unable to kill $FREEZE_SESSION_PID." >> "$LOGFILE"
    fi

    if [ -f "${MYSQL_OUTPUT_FILE}" ]; then
      FREEZE_THREAD_ID=$(/bin/head -n 1 "${MYSQL_OUTPUT_FILE}")

      if [ -n "$FREEZE_THREAD_ID" ]; then
        echo "$(date -Ins) - Killing MySQL thread. ID is $FREEZE_THREAD_ID." >> "$LOGFILE"
        if mysqladmin --user="$MYSQL_USER" --password="$mysql_password" kill "${FREEZE_THREAD_ID}" ; then
            echo "$(date -Ins) - $FREEZE_THREAD_ID thread was killed." >> "$LOGFILE"
        else
            echo "$(date -Ins) - Unable to kill thread $FREEZE_THREAD_ID." >> "$LOGFILE"
        fi
      else
        echo "$(date -Ins) - Temp file does not contain thread ID." >> "$LOGFILE"
      fi
    fi

    exit 2
  fi

  echo "$(date -Ins) - Waiting for MySQL to freeze tables. Making try $attempts..." >> "$LOGFILE"

done

echo $FREEZE_SESSION_PID > "$MYSQL_FREEZE_LOCKFILE"

echo "$(date -Ins) - Freeze successful." >> "$LOGFILE"