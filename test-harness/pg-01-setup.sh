#!/bin/bash

mkdir -p tmp-postgresql

# This is unpacked tarball from http://homepages.cwi.nl/~boncz/job/imdb.tgz
#  the csv files use {empty space} for NULL values.
if [ ! -d imdb-2014-csv-postgresql ] ; then
  cp -r /optane/data/imdb-2014-postgresql imdb-2014-csv-postgresql
fi

