# Download-Checksum

## Scope

This project is composed of two distinct elements; a bash script that populate
a sqlite database with given files (adding checksum and other details), and a
small Flask app that takes a checksum and return the corresponding file to the
user if any matching file on the database is found.

## Requirements

- sqlite3/unzip bash programs installed
- Python 3.10 or better for Flask app

## Instructions

1. Clone the repository
2. Copy the .env-example to .env and adjust the variables
3. Add some files to the db: `find /path/to/scan -type f -exec ./add_file.sh {} \;`
4. Run Flask app

## Usage

`wget http://localhost:5000/checksum-downloader/<checksum>`
