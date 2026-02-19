#!/bin/bash

source local_dataset_path.sh

# This is made as follows:
#  - Get the tarball from http://homepages.cwi.nl/~boncz/job/imdb.tgz
#  - import into PostgreSQL and export back with \N for NULL values
#  - Several manual edits where the '\' character at the end of field is not
#    escaped

if [ ! -d imdb-2014-csv-mysql ] ; then

  if [ ! -d $LOCAL_DATASET_PATH/imdb-2014-mysql ] ; then
    echo "Failed to find mysql dataset at $LOCAL_DATASET_PATH/imdb-2014-mysql"
    exit 1
  fi
  cp -r $LOCAL_DATASET_PATH/imdb-2014-mysql imdb-2014-csv-mysql
fi

mkdir -p tmp-mariadb

