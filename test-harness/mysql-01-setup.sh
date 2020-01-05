#!/bin/bash

mkdir -p tmp-mysql

if [ ! -d imdb-2014-csv-mysql ] ; then
  cp -r /optane/data/imdb-2014-mysql imdb-2014-csv-mysql
fi
