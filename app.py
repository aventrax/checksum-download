import os
import sqlite3
import sys
from dotenv import load_dotenv
from flask import Flask, abort, send_file
from zipfile import ZipFile


load_dotenv()

if not os.environ.get('DATABASE', None):
    print('Missing DATABASE variable on .env file')
    sys.exit()

app = Flask(__name__)


@app.route(os.environ.get('VIRTUALDIRPATH', '') + '/<checksum>', methods=['GET'])
def checksum_download(checksum):
    """
    Search for requested checksum and return matching file
    """

    db_file = os.environ['DATABASE']

    with sqlite3.connect("file:{}?mode=ro".format(db_file), uri=True) as conn:
        conn.row_factory = sqlite3.Row
        query = "SELECT * FROM files WHERE checksum='{}'".format(checksum)
        cur = conn.cursor()
        cur.execute(query)
        row = cur.fetchone()

    if not row:
        return abort(404)

    checksum = row['checksum']
    checksum_type = row['checksum_type']
    path = row['path']
    archive = row['archive']
    archive_type = row['archive_type']

    if not archive and os.access(path, os.R_OK):
        return send_file(path, as_attachment=True, download_name=os.path.basename(path))

    if archive_type == 'zip' and os.access(archive, os.R_OK):
        try:
            with ZipFile(archive, 'r') as zf:
                return send_file(zf.open(path), as_attachment=True, download_name=os.path.basename(path))
        except:
            abort(533)

    return abort(500)


if __name__ == '__main__':
    app.run(host=os.environ.get('IP_ADDRESS', '0.0.0.0'), port=os.environ.get('PORT', 1234))
