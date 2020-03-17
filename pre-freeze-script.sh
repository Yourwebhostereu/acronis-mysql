#!/usr/bin/env bash

DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$DIR"/capture-data-config.sh

echo "$(date -Ins) ---------------------------------------------------------------------" >> "$LOGFILE"

echo "$(date -Ins) - Pre-capture data script started." >> "$LOGFILE"

if [ "$MYSQL_FREEZE" -eq "1" ]; then
    if mysqladmin ping > /dev/null 2>&1; then
        source "$DIR"/freeze-mysql.sh
    else
        echo "$(date -Ins) - MySQL server is not available." >> "$LOGFILE"
    fi
fi


echo "$(date -Ins) - Pre-capture data script finished." >> "$LOGFILE"
