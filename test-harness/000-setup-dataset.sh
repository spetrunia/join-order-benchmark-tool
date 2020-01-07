#!/bin/bash

if [ ! -d /optane/data/imdb-2014-mysql ] ; then
  mkdir -p imdb-2014-csv-postgresql
  (cd imdb-2014-csv-postgresql;
   wget http://homepages.cwi.nl/~boncz/job/imdb.tgz;
   tar zxvf imdb.tgz)
fi

if [ ! -d postgresql-12.1-inst ] ; then
  bash setup-server/setup-postgresql-12.sh
fi

bash test-harness/pg-10-load-data.sh

mkdir -p ./imdb-2014-csv-mysql

cat test-harness/table_list.txt | while read a ; do
  echo "\\copy $a to './imdb-2014-csv-mysql/$a.csv' with (format csv, null '\\N', escape '\\') ;"
done > tmp-postgresql/dump-to-mysql.sql

source psql-vars.sh
$PSQL test < tmp-postgresql/dump-to-mysql.sql

patch -p0 < test-harness/mysql-fix-title.diff
patch -p0 < test-harness/mysql-fix-person-info.diff

