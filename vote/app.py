from flask import Flask, render_template, request, make_response, g
from redis import Redis
import os
import socket
import random
import json
import logging


CT_g = 0
ST_g = 0
TP_g = 0
LP_g = 0
LPE_g = 0
SEE_g = 0
hostname = socket.gethostname()

app = Flask(__name__)

gunicorn_error_logger = logging.getLogger('gunicorn.error')
app.logger.handlers.extend(gunicorn_error_logger.handlers)
app.logger.setLevel(logging.INFO)

def get_redis():
    if not hasattr(g, 'redis'):
        g.redis = Redis(host="redis", db=0, socket_timeout=5)
    return g.redis

@app.route("/", methods=['POST','GET']) 
def hello():
    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    
    if request.method == 'POST':
        redis = get_redis()
        CT_g = request.form['CT']
        ST_g = request.form['ST']
        TP_g = request.form['TP']
        LP_g = request.form['LP']
        LPE_g = request.form['LPE']
        SEE_g = request.form['SEE']
        data = json.dumps({'voter_id': voter_id, 'CT': CT_g, 'ST' : ST_g, 'TP' : TP_g, 'LP' : LP_g, 'LPE' : LPE_g, 'SEE' : SEE_g})
        app.logger.info('Received Marks :', 'CT: ', CT_g, 'ST:', ST_g, 'TP:', TP_g, 'LP:', LP_g, 'LPE:', LPE_g, 'SEE:', SEE_g)
        redis.rpush('votes', data)
        

    resp = make_response(render_template(
        'index.html',
        CT_g=CT,
        ST=ST_g,
        TP=TP_g,
        LP=LP_g,
        LPE=LPE_g,
        SEE=SEE_g,
        hostname=hostname
    ))
    resp.set_cookie('voter_id', voter_id)
    return resp


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True, threaded=True)
