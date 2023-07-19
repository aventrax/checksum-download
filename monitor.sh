#!/bin/bash
#
# Usage: ./monitor.sh

set -o allexport
source .env
set +o allexport

if [[ -z "$DATABASE" ]]; then
  echo "Ensure DATABASE= is defined on .env file"
  exit 1
elif [[ -z "$MONITOR_DIRS"  ]]; then
  echo "Ensure MONITOR_DIRS= is defined on .env file"
  exit 1
elif [[ -z "$MONITOR_EVENTS" ]]; then
  echo "Ensure MONITOR_EVENTS= is defined on .env file"
  exit 1
fi

for d in $MONITOR_DIRS; do
  if [[ ! -d $d ]]; then
    echo "$d is not a directory"
    exit 1
  fi
done

inotifywait -q -mr --format '%e; %w%f' -e $MONITOR_EVENTS $MONITOR_DIRS|while read L; do
  e=$(echo $L|cut -d\; -f1)
  f=$(echo $L|cut -d\; -f2-100)
  if [[ "$e" =~ MOVED_TO|CLOSE_WRITE ]]; then
    echo "Adding file: $f" && ./add_file.sh $f
  elif [[ "$e" =~ DELETE ]]; then
    echo "Removing file: $f"
    sqlite3 $DATABASE "DELETE FROM files WHERE path='$f'"
  fi
done

