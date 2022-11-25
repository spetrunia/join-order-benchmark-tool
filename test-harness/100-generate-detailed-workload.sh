#!/bin/bash

#
# Generate a workload that collects a lot of details
#

OUT_DIR="tmp-mariadb/run-queries-analyze"

RUN_SCRIPT="$OUT_DIR/run.sh"

rm -rf $OUT_DIR
mkdir -p $OUT_DIR

echo "#!/bin/bash" >> $RUN_SCRIPT
echo 'source mysql-vars.sh' >> $RUN_SCRIPT

cp test-harness/db_init_mariadb.sql $OUT_DIR/init.sql

echo "\$MYSQL \$MYSQL_ARGS --raw imdbload < $OUT_DIR/init.sql" >> $RUN_SCRIPT

for FILE in queries-mysql/[0-9]*.sql ; do 

  QUERY_NAME=`basename $FILE`
  QUERY_NAME=${QUERY_NAME/.sql/}

# For each query, we need to do these steps:
#
# * Enable optimizer trace
# * Pre-run step (note the start time)
# * Run the ANALYZE, capturing the output
# * Post-run step (note the end time)
# * Save the optimizer trace
#
# All of the above needs to be run from the same connection.
# That is, we need to run it from the same script.

 (
   echo "-- ### QUERY $QUERY_NAME ##########################################"
   echo "-- ### Warmup and trace"
   echo "set optimizer_trace_max_mem_size=64*1024*1024;"
   echo "set optimizer_trace=1;"
   echo "ANALYZE FORMAT=JSON"
   cat $FILE
   echo "select * from information_schema.optimizer_trace;"
   echo "set optimizer_trace=0;"
   echo "-- ### QUERY $QUERY_NAME test run"
   sed -e "s/__QUERY_NAME__/$QUERY_NAME/" < test-harness/query_start_mariadb.sql
   echo "ANALYZE FORMAT=JSON"
   cat $FILE
   cat test-harness/query_end_mariadb.sql
 ) > $OUT_DIR/$QUERY_NAME.sql

 echo "\$MYSQL \$MYSQL_ARGS --raw imdbload < $OUT_DIR/$QUERY_NAME.sql >$OUT_DIR/$QUERY_NAME.out1"  >> $RUN_SCRIPT

done


