#!/bin/bash

source psql-vars.sh

$PSQL test < tmp-postgresql/run-queries.sql | tee tmp-postgresql/log.txt

