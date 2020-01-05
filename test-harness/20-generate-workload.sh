#!/bin/bash

(

cat test-harness/db_init_mariadb.sql

# for FILE in join-order-benchmark/[0-9]*.sql ; do 
for FILE in join-order-benchmark-2/queries/[0-9]*.sql ; do 

  QUERY_NAME=`basename $FILE`
  QUERY_NAME=${QUERY_NAME/.sql/}
  #echo $QUERY_NAME;

  echo "-- ### QUERY $QUERY_NAME ##########################################"
  
  echo "-- ### Warmup "
  cat $FILE

  echo "-- ### Test run "
  sed -e "s/__QUERY_NAME__/$QUERY_NAME/" < test-harness/query_start_mariadb.sql
  cat $FILE

  cat test-harness/query_end_mariadb.sql
done

) > tmp-mariadb/run-queries.sql

