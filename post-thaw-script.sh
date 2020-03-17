#!/usr/bin/env bash

DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$DIR"/capture-data-config.sh

echo "$(date -Ins) - Post-capture data script started." >> "$LOGFILE"


if [ -f "$MYSQL_FREEZE_LOCKFILE" ]; then
  FREEZE_SESSION_PID=$(/bin/cat "$MYSQL_FREEZE_LOCKFILE")

  if [ -n "$FREEZE_SESSION_PID" ]; then
    echo "$(date -Ins) - Terminating freeze session. PID is $FREEZE_SESSION_PID." >> "$LOGFILE"
    if pkill -9 -P $FREEZE_SESSION_PID ; then
        echo "$(date -Ins) - $FREEZE_SESSION_PID was killed." >> "$LOGFILE"
    else
        echo "$(date -Ins) - Unable to kill $FREEZE_SESSION_PID." >> "$LOGFILE"
    fi
  else
    echo "$(date -Ins) - Lock file does not contain pid of mysql freeze session." >> "$LOGFILE"
  fi

  echo "$(date -Ins) - Deleting freeze lock file..." >> "$LOGFILE"
  /bin/rm -f "$MYSQL_FREEZE_LOCKFILE"
fi

echo "$(date -Ins) - Post-capture data script finished." >> "$LOGFILE"
