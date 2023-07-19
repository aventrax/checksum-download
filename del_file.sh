#!/bin/bash
#
# Usage: ./del_file.sh /path/to/file

set -o allexport
source .env
set +o allexport

if [[ -z "$DATABASE" ]]; then
  echo "Missing 'DATABASE' on .env file"
  exit 1
fi

f=$*

if [[ ! "$f" =~ ^/ ]]; then
  echo "Script argument must start with a slash"
  exit 1
fi

sqlite3 $DATABASE "DELETE FROM files WHERE path='$f'"

