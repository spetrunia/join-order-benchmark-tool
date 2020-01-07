#!/bin/bash

# prepare-dataset.sh will install PostgreSQL and load 
# the dataset there in order to convert it to MySQL form

if [ ! -d pgdata ] ; then
bash setup-server/setup-postgresql-12.sh
bash test-harness/pg-01-setup.sh
bash test-harness/pg-10-load-data.sh
fi

bash test-harness/pg-20-generate-workload.sh
bash test-harness/pg-30-run-workload.sh
bash test-harness/pg-40-save-result.sh
