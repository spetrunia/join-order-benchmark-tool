#!/bin/bash

source local_dataset_path.sh

mkdir -p tmp-mariadb

# This is made as follows:
#  - Get the tarball from http://homepages.cwi.nl/~boncz/job/imdb.tgz
#  - import into PostgreSQL and export back with \N for NULL values
#  - Several manual edits where the '\' character at the end of field is not
#    escaped

if [ ! -d imdb-2014-csv-mysql ] ; then
  cp -r $LOCAL_DATASET_PATH/imdb-2014-mysql imdb-2014-csv-mysql
fi

