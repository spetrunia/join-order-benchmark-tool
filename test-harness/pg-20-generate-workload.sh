#!/bin/bash

(

cat test-harness/db_init_pg.sql

for FILE in  queries-orig/[0-9]*.sql ; do 

  QUERY_NAME=`basename $FILE`
  QUERY_NAME=${QUERY_NAME/.sql/}
  #echo $QUERY_NAME;

  echo "-- ### QUERY $QUERY_NAME ##########################################"
  
  echo "-- ### Warmup "
  cat $FILE

  echo "-- ### Test run "
  sed -e "s/__QUERY_NAME__/$QUERY_NAME/" < test-harness/query_start_pg.sql
  cat $FILE

  cat test-harness/query_end_pg.sql
done

) > tmp-postgresql/run-queries.sql

