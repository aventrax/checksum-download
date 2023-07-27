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
  sqlite3 $DATABASE "CREATE TABLE files ('id'	INTEGER, checksum TEXT NOT NULL, checksum_type TEXT NOT NULL DEFAULT 'sha1', path TEXT NOT NULL, archive TEXT DEFAULT NULL, archive_type TEXT DEFAULT NULL, PRIMARY KEY('id' AUTOINCREMENT));"
fi

# ONLY for .exe or .dll extensions
if [[ "$f" =~ \.[eE][xX][eE]$|\.[dD][lL][lL]$ ]]; then
  sha1=$(sha1sum "$f"|cut -d\  -f1)
  echo "Adding file: $f"
  sqlite3 $DATABASE "INSERT INTO files (checksum, path) VALUES ('$sha1', '$f');"

# ONLY for 'zip' file type (non including 7zip)
elif [[ "$(file $f|cut -d\: -f2-100)" =~ \ [zZ][iI][pP] ]]; then
  unzip -Z1 "$f"|while read fz; do
    sha1=$(unzip -p "$f" "$fz"|sha1sum|cut -d\  -f1)
    echo "Adding file: $fz (archive: $f)"
    sqlite3 $DATABASE "INSERT INTO files (checksum, path, archive, archive_type) VALUES ('$sha1', '$fz', '$f', 'zip');"
  done

# END processing
else
  echo "$f does not appear to be a exe/dll or zip file"
  exit 1
fi
