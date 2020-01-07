#!/bin/bash

source psql-vars.sh

cat test-harness/table_list.txt | while read a ; do 
  echo "\\copy $a from './imdb-2014-csv-postgresql/$a.csv' with (format csv, escape '\') ;"
done > tmp-postgresql/load-data.sql

$PSQL test < test-harness/schema-original.sql
$PSQL test < tmp-postgresql/load-data.sql 
$PSQL test < test-harness/fkindexes.sql
echo "ANALYZE" | $PSQL test

