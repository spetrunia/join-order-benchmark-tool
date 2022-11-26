#!/bin/bash

# A script to run individual queries

source mysql-vars.sh
$MYSQL $MYSQL_ARGS --raw imdbload

