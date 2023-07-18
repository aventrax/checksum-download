# Download-Checksum

## Scope

This project scans a folder for certain type of files, that takes their checksums
and populate a sqlite database used by a Flask app to return files based on their
checksums. The database is kept updated by a script using inotify-tools.

There are three distinct elements:

- A bash script that populate a sqlite database with given files
- A small Flask app that takes a checksum and return the corresponding file
- A script monitoring a folder updating the database if necessary

Files into zip archives are managed.

## Requirements

- Python3 (better with a virtualenv)
- sqlite3/unzip/inotify-tools packages installed

## Instructions

1. Clone the repository
2. Copy the .env-example to .env and adjust the variables
3. Add some files to the db: `find /path/to/scan -type f -exec ./add_file.sh {} \;`
4. Run Flask app

## Usage

`wget http://localhost:5000/checksum-downloader/<checksum>`
