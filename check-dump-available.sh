#!/bin/bash

source local_dataset_path.sh

if [ ! -f $LOCAL_DUMP_FILE ]; then

  echo "File LOCAL_DUMP_FILE=$LOCAL_DUMP_FILE not found."
  echo "Download this file: "
  echo "  https://drive.google.com/file/d/1pXupl8V8uhTfSG9Tsp4JTbCMTncsl6aR/view "
  echo "and set LOCAL_DUMP_FILE in local_dataset_path.sh to point to it"
  echo  ""
  exit 1
fi

