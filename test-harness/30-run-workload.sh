#!/bin/bash

#source tmp-mariadb/client-config.sh
source mysql-vars.sh

$MYSQL $MYSQL_ARGS imdbload < tmp-mariadb/run-queries.sql | tee tmp-mariadb/log.txt

