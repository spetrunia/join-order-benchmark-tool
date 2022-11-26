#!/bin/bash

set -e 

source mysql-vars.sh
source local_dataset_path.sh
source check-dump-available.sh

mkdir -p tmp-mariadb

echo $MYSQL $MYSQL_ARGS -e "drop database if exists imdbload"
$MYSQL $MYSQL_ARGS -e "drop database if exists imdbload"
$MYSQL $MYSQL_ARGS -e "create database imdbload"

bunzip2 -c < $LOCAL_DUMP_FILE | $MYSQL $MYSQL_ARGS imdbload

cat test-harness/table_list.txt | while read a ; do 
  echo "analyze table $a;"
done > tmp-mariadb/analyze-tables.sql

$MYSQL $MYSQL_ARGS imdbload < tmp-mariadb/analyze-tables.sql
