# Download-Checksum

## Scope

This project scans a folder for certain type of files, than takes its checksums
and populate a sqlite database used by a Flask app to return files requested by
its checksums. The database is kept updated by a script using inotify-tools.

There are three distinct elements:

- Script that populates a sqlite database with given files
- Flask app that takes a checksum and return the corresponding file
- Script monitoring a folder updating the database if necessary

Files into zip archives are extracted and checksummed.

SHA1 checksum is used but its easy to change.

## Requirements

- Python 3.x
- sqlite3/unzip/inotify-tools packages installed

## Instructions

1. Clone the repository
2. Copy the .env-example to .env and adjust the variables
3. Add some files to the db: `find /path/to/scan -type f -exec ./add_file.sh {} \;`
4. Run Flask app

Eventually copy the *.service files into the ~/.config/systemd/user/ folder, adjust
the WorkingDirectory and enable the services:

- `systemctl --user daemon-reload`
- `systemctl --user start checksum-download.service`
- `systemctl --user enable checksum-download.service`
- `systemctl --user start checksum-monitor.service`
- `systemctl --user enable checksum-monitor.service`


## Usage

Scan a folder:
`find /path/to/scan -type f -exec ./add_file.sh {} \;`

Download file by its SHA1 checksum:
`wget http://localhost:5000/checksum-downloader/<checksum>`
