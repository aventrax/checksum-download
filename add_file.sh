#!/bin/bash
#
# Usage: find /path/to/scan -type f -exec ./add_file.sh {} \;

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

if [ ! -f $DATABASE ]; then
  echo "Database not found, creating an empty one"
  sqlite3 $DATABASE "CREATE TABLE files (checksum TEXT NOT NULL UNIQUE, checksum_type TEXT NOT NULL DEFAULT 'SHA1', path TEXT NOT NULL, archive INTEGER DEFAULT NULL, archive_type INTEGER DEFAULT NULL, PRIMARY KEY(checksum));"
fi

if [[ "$f" =~ \.[eE][xX][eE]$|\.[dD][lL][lL]$ ]]; then
  sha1=$(sha1sum "$f"|cut -d\  -f1)
  if [ $(sqlite3 $DATABASE "SELECT COUNT(*) FROM files WHERE checksum='$sha1'") -eq 0 ]; then
    echo "Adding file: $f"
    sqlite3 $DATABASE "INSERT INTO files (checksum, path) VALUES ('$sha1', '$f');"
  fi

elif [[ "$f" =~ \.[zZ][iI][pP] ]]; then
  unzip -Z1 "$f"|while read fz; do
    sha1=$(unzip -p "$f" "$fz"|sha1sum|cut -d\  -f1)
    if [ $(sqlite3 $DATABASE "SELECT COUNT(*) FROM files WHERE checksum='$sha1'") -eq 0 ]; then
      sqlite3 $DATABASE "INSERT INTO files (checksum, path, archive, archive_type) VALUES ('$sha1', '$fz', '$f', 'zip');"
    fi
  done
else
  echo "$f does not appear to be a exe/dll or zip file"
  exit 1
fi