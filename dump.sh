#!/usr/bin/env bash
# Copyright 2020 Daniel Koop, Yourwebhoster.eu <daniel@yourwebhoster.eu>

# Set the configuration
DIR="$(dirname "${BASH_SOURCE[0]}")"
mysql_bin=`which mysql`
mysqld_bin=`which mysqld_safe`
mysqldump_bin=`which mysqldump`
mysqladmin_bin=`which mysqladmin`
source "$DIR"/capture-data-config.sh

function usage()
{
    echo "usage: dump.sh [-d|--database datatabase ] | [-h|--help]"
}

# Find the parameters
while [ "$1" != "" ]; do
    case $1 in
        -d | --database )           shift
                                database=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Check if a database has been defined.
if [ -z $database ]
then
    echo "No database has been defined."
    echo "User this script as dump.sh --database DATABASENAME"
    echo "Or as dump.sh -d DATABASENAME"
    echo "Aborting..."
    exit 1;
fi

# Launch MySQL
echo "###################";
echo "LAUNCH TEMPORARY MYSQL INSTANCE"
$mysqld_bin --defaults-file=$DIR/conf/my.cnf&

echo "MySQL has launched. Waiting 10 seconds to complete startup..."
sleep 10

# Check if we can connect
connect_attempts=0
while !($mysqladmin_bin --defaults-extra-file=$DIR/conf/my_extra.cnf --host=localhost --protocol=SOCKET --socket=/tmp_mysql/mysql.sock ping)
do
    
    if [ $connect_attempts -ge 10 ];
    then
        echo "Unable to connect to temporary MySQL instance. Aborting..."
        echo "Check if the MySQL instance is still running manually and stop the process."
        echo "Check the log files in /tmp_mysql/mysql.log"
        echo "In some occassions as longer recovery time is required to make the databases accessible."
        echo "You can use the following command for this:"
        echo ""
        echo 'kill `cat /tmp_mysql/mysqld.pid`'
        echo ""
        exit 1;
    fi
    
    # Increase connection attempts
    connect_attempts=$((connect_attempts+1))
    echo "MySQL has not finished starting yet, waiting 10 seconds [attempt $connect_attempts]...";
    sleep 10

done

# Create a database dump
echo "###################";
echo "CREATING DATABASE DUMP"

$mysqldump_bin --defaults-extra-file=$DIR/conf/my_extra.cnf \
--host=localhost \
--protocol=SOCKET \
--socket=/tmp_mysql/mysql.sock \
--triggers \
--routines \
--events $database > /tmp_mysql/$database.sql

echo "###################";
echo "SHUTTING DOWN TEMPORARY MYSQL INSTANCE"
$mysql_bin --defaults-extra-file=$DIR/conf/my_extra.cnf \
--host=localhost \
--protocol=SOCKET \
--socket=/tmp_mysql/mysql.sock \
-e 'shutdown'

echo "DONE"
echo ""
echo "Dumped database $database to /tmp_mysql/$database.sql"
echo "Restore with a command like:"
echo 'mysql < /tmp_mysql/$database.sql'