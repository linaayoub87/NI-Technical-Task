from flask import Flask, url_for
from flask import Response
import json
import urllib.request
import logging

log = logging.getLogger()
log.setLevel(logging.INFO)
app = Flask(__name__)

@app.route('/', methods = ['GET'])
def api():
    instanceid = ''
    try:
            instanceid = urllib.request.urlopen('http://169.254.169.254/latest/meta-data/instance-id').read().decode()
    except:
            log.error('An error occurred.')
    data = {
            'message'  : 'Hello world!'}
    js = json.dumps(data)
    resp = Response(js, status=200, mimetype='application/json')
    resp.headers['instance_id'] = instanceid
    return resp

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
