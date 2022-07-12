#!/bin/bash

source local_dataset_path.sh
mkdir -p tmp-mysql

if [ ! -d imdb-2014-csv-mysql ] ; then
  cp -r $LOCAL_DATASET_PATH/imdb-2014-mysql imdb-2014-csv-mysql
fi
