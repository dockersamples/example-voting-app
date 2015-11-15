import time
from redis import Redis, ConnectionError


def connect_to_redis(host):
    time.sleep(2)
    print "Connecting to redis"

    while True:
        try:
            redis = Redis(host=host, db=0)
            redis.ping()
            print "Connected to redis"
            return redis
        except ConnectionError:
            print "Failed to connect to redis - retrying"
            time.sleep(1)
