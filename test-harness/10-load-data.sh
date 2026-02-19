#!/bin/bash

source mysql-vars.sh

sleep 10;
#echo $MYSQL_CMD $MYSQL_ARGS -e "drop database if exists imdbload"
$MYSQL_CMD $MYSQL_ARGS -e "drop database if exists imdbload"
$MYSQL_CMD $MYSQL_ARGS -e "create database imdbload"

# $MYSQL $MYSQL_ARGS imdbload < test-harness/schema-original.sql
$MYSQL_CMD $MYSQL_ARGS imdbload < test-harness/schema-winkyao.sql

cat test-harness/table_list.txt | while read a ; do 
echo "LOAD DATA INFILE '`pwd`/imdb-2014-csv-mysql/$a.csv' INTO TABLE $a FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"';"
done > tmp-mariadb/load-data.sql

$MYSQL_CMD $MYSQL_ARGS imdbload < tmp-mariadb/load-data.sql
$MYSQL_CMD $MYSQL_ARGS imdbload < test-harness/fkindexes.sql

cat test-harness/table_list.txt | while read a ; do 
  echo "analyze table $a;"
done > tmp-mariadb/analyze-tables.sql

$MYSQL_CMD $MYSQL_ARGS imdbload < tmp-mariadb/analyze-tables.sql
