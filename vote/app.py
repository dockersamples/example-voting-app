from flask import Flask, render_template, request, make_response, g
from redis import Redis
import os
import socket
import random
import json
import logging

option_a = os.getenv('OPTION_A', "Cats")
option_b = os.getenv('OPTION_B', "Dogs")
option_c = os.getenv('OPTION_C', "Birds")
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

    vote = None


    if request.method == 'POST':
        vote = request.form.get('vote')

        if vote not in ('a', 'b', 'c'):
            return 'Invalid voting option.', 400


        redis = get_redis()

        # Reserve this browser's voter ID only if it has not voted before.
        reservation_key = 'voted:' + voter_id
        reserved = redis.set(reservation_key, vote, nx=True)

        if not reserved:
            return 'A vote has already been submitted from this browser.', 409

        app.logger.info('Received vote for %s', vote)
        data = json.dumps({'voter_id': voter_id, 'vote': vote})

        try:
            redis.rpush('votes', data)
        except Exception:
            # Release the reservation if queueing fails.
            redis.delete(reservation_key)
            raise


    resp = make_response(render_template(
        'index.html',
        option_a=option_a,
        option_b=option_b,
        option_c=option_c,
        hostname=hostname,
        vote=vote,
    ))
    resp.set_cookie('voter_id', voter_id)
    return resp


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True, threaded=True)
