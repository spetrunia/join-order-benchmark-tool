#!/bin/bash

set -e 
source mysql-vars.sh

client_attempts=0
while true ; do
  echo $MYSQL_CMD $MYSQL_ARGS -e "select version()";
  failed_start=0;
  $MYSQL_CMD $MYSQL_ARGS -e "select version()" || failed_start=1

  if [ $failed_start -eq 0 ]; then
    break
  fi
  sleep 1

  client_attempts=$((client_attempts + 1))
  if [ $client_attempts -ge 30 ]; then
    echo "Failed to start server."
    exit 1
  fi
done

