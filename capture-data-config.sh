#!/usr/bin/env bash

DIR="$(dirname "${BASH_SOURCE[0]}")"

LOGFILE="$DIR/log/mysql_dump.log"

MYSQL_USER=
MYSQL_PASSWORD_PATH=

MYSQL_FREEZE_LOCKFILE="$DIR/freeze_mysql.lock"
MYSQL_OUTPUT_FILE="$DIR/freeze_mysql.out"

# You can configure the following parameters. Please read the user's guide before editing the parameters.

# MYSQL_FREEZE
# 0 - don't lock mysql tables before backup.
# 1 - lock mysql tables before backup.
MYSQL_FREEZE=1

# MYSQL_FREEZE_TIMEOUT
# Specified in seconds.
MYSQL_FREEZE_TIMEOUT=120

# MYSQL_FREEZE_SNAPSHOT_TIMEOUT
# Specified in seconds.
MYSQL_FREEZE_SNAPSHOT_TIMEOUT=10

# MYSQL_FREEZE_ONLY_MYISAM
# 0 - lock all tables before backup.
# 1 - lock only MyISAM tables before backup.
MYSQL_FREEZE_ONLY_MYISAM=0

if [ -f /root/.my.cnf ]; then
    echo "$(date -Ins) - MySQL .my.cnf exists." >> "$LOGFILE"
    MYSQL_USER=`awk -F "=" '/user/ {print $2}' /root/.my.cnf`
    mysql_password=`awk -F "=" '/password/ {print $2}' /root/.my.cnf`
elif [ -f /usr/local/directadmin/conf/my.cnf ]; then
    echo "$(date -Ins) - DirectAdmin detected - loading my.cnf." >> "$LOGFILE"
    MYSQL_USER=`awk -F "=" '/user/ {print $2}' /usr/local/directadmin/conf/my.cnf`
    mysql_password=`awk -F "=" '/password/ {print $2}' /usr/local/directadmin/conf/my.cnf`
fi