from flask import Flask, render_template, request, make_response, g
from redis import Redis

import os
import socket
import random
import json
import logging

OPTION_A = os.environ.get('OPTION_A', "Cats")
OPTION_B = os.environ.get('OPTION_B', "Dogs")

REDIS_HOST = os.environ.get('REDIS_HOST')
REDIS_PORT = os.environ.get('REDIS_PORT')
REDIS_DB = os.environ.get('REDIS_DB')

LOGLEVEL = os.environ.get('LOGLEVEL', 'INFO').upper()

HOSTNAME = socket.gethostname()

app = Flask(__name__)

app.logger.info("add gunicorn error logger")
gunicorn_error_logger = logging.getLogger('gunicorn.error')
app.logger.handlers.extend(gunicorn_error_logger.handlers)
app.logger.setLevel(LOGLEVEL)

app.logger.info("Connection to redis redis://{0}:{1}/{2}".format(REDIS_HOST, REDIS_PORT, REDIS_DB))
redis = Redis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, socket_timeout=5)
app.logger.info("Connected to redis redis://{0}:{1}/{2}".format(REDIS_HOST, REDIS_PORT, REDIS_DB))

@app.route("/", methods=['POST','GET'])
def hello():

    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        app.logger.debug("voter_id not found in cookie, generating new one")
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = None

    if request.method == 'POST':
        vote = request.form['vote']
        app.logger.debug("Received POST request with {}".format(vote))
        data = json.dumps({'voter_id': voter_id, 'vote': vote})
        redis.rpush('votes', data)
        app.logger.debug("Vote pushed to redis")

    resp = make_response(render_template(
        'index.html',
        option_a=OPTION_A,
        option_b=OPTION_B,
        hostname=HOSTNAME,
        vote=vote,
    ))
    resp.set_cookie('voter_id', voter_id)
    return resp
