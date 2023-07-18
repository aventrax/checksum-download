#!/bin/bash


if [[ ! -d $1 ]]; then
  echo "First argument must be a directory"
  exit 1
fi

inotifywait -q -mr --format '%w%f' -e close_write,moved_to "$1"|while read file; do

  sleep 1; [[ -f $file ]] && ./add_file.sh $file

done
