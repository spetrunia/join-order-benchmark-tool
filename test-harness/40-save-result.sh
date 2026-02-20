#!/bin/bash

source mysql-vars.sh

VERSION=`$MYSQL_CMD $MYSQL_ARGS -BN -e'select version()'`
echo "select * from my_job_result" | $MYSQL_CMD $MYSQL_ARGS imdbload | tee -a tmp-mariadb/$VERSION-result.txt

