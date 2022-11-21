#!/bin/bash

source mysql-vars.sh


echo "set histogram_type=json_hb;" > tmp-mariadb/eits-analyze.sql

(
cat test-harness/table_list.txt | while read a ; do 
echo "analyze table $a persistent for all;"
done
)>> tmp-mariadb/eits-analyze.sql

$MYSQL $MYSQL_ARGS imdbload < tmp-mariadb/eits-analyze.sql

