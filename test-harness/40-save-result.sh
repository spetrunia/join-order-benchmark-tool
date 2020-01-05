#!/bin/bash

source mysql-vars.sh

echo "select * from my_job_result" | $MYSQL $MYSQL_ARGS imdbload | tee -a tmp-mariadb/result.txt

