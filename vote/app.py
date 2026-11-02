"""Vote front end, instrumented for SRE work.

Changes from the upstream sample:
  * Prometheus metrics at /metrics (request count, latency histogram, vote
    enqueue failures), safe across multiple gunicorn workers.
  * /healthz (liveness: is the process up?) vs /readyz (readiness: can I reach
    Redis?), so Kubernetes stops routing traffic instead of restarting pods
    when a dependency is down.
  * Redis failures return a clean 503 instead of an unhandled 500 + stack trace.
"""
import json
import logging
import os
import random
import socket
import time

from flask import Flask, Response, g, make_response, render_template, request
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    CollectorRegistry,
    Counter,
    Histogram,
    generate_latest,
    multiprocess,
)
from redis import Redis
from redis.exceptions import RedisError

option_a = os.getenv("OPTION_A", "Cats")
option_b = os.getenv("OPTION_B", "Dogs")
redis_host = os.getenv("REDIS_HOST", "redis")
redis_timeout = float(os.getenv("REDIS_TIMEOUT_SECONDS", "0.5"))
hostname = socket.gethostname()

app = Flask(__name__)

gunicorn_error_logger = logging.getLogger("gunicorn.error")
app.logger.handlers.extend(gunicorn_error_logger.handlers)
app.logger.setLevel(logging.INFO)

# Buckets chosen around the 300 ms latency SLO so the threshold sits on a
# bucket boundary and the SLI can be computed exactly.
LATENCY_BUCKETS = (0.005, 0.01, 0.025, 0.05, 0.1, 0.2, 0.3, 0.5, 1.0, 2.5, 5.0)

REQUESTS = Counter(
    "vote_http_requests_total",
    "HTTP requests served by the vote front end.",
    ["method", "route", "status"],
)
LATENCY = Histogram(
    "vote_http_request_duration_seconds",
    "HTTP request latency for the vote front end.",
    ["method", "route"],
    buckets=LATENCY_BUCKETS,
)
VOTES = Counter("vote_votes_total", "Votes successfully enqueued.", ["option"])
ENQUEUE_FAILURES = Counter(
    "vote_enqueue_failures_total", "Votes that could not be written to Redis."
)

# Routes that are infrastructure, not user traffic. They are excluded from
# the SLIs so probes and scrapes don't inflate availability.
UNTRACKED_ROUTES = {"/metrics", "/healthz", "/readyz"}


def get_redis():
    if not hasattr(g, "redis"):
        g.redis = Redis(
            host=redis_host,
            db=0,
            socket_timeout=redis_timeout,
            socket_connect_timeout=redis_timeout,
        )
    return g.redis


@app.before_request
def start_timer():
    g.start = time.perf_counter()


@app.after_request
def record_metrics(response):
    route = request.url_rule.rule if request.url_rule else "unmatched"
    if route not in UNTRACKED_ROUTES:
        LATENCY.labels(request.method, route).observe(time.perf_counter() - g.start)
        REQUESTS.labels(request.method, route, str(response.status_code)).inc()
    return response


@app.route("/", methods=["POST", "GET"])
def hello():
    voter_id = request.cookies.get("voter_id")
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:]

    vote = None

    if request.method == "POST":
        vote = request.form.get("vote")
        if vote not in ("a", "b"):
            return Response("Invalid vote option.\n", status=400)
        data = json.dumps({"voter_id": voter_id, "vote": vote})
        try:
            get_redis().rpush("votes", data)
        except RedisError as exc:
            ENQUEUE_FAILURES.inc()
            app.logger.error("Failed to enqueue vote: %s", exc)
            return Response("Vote service temporarily unavailable.\n", status=503)
        VOTES.labels(vote).inc()
        app.logger.info("Received vote for %s", vote)

    resp = make_response(
        render_template(
            "index.html",
            option_a=option_a,
            option_b=option_b,
            hostname=hostname,
            vote=vote,
        )
    )
    resp.set_cookie("voter_id", voter_id)
    return resp


@app.route("/healthz")
def healthz():
    # Liveness: only says the process can serve HTTP. Deliberately does NOT
    # check Redis, otherwise a Redis outage would restart every vote pod.
    return Response("ok\n", mimetype="text/plain")


@app.route("/readyz")
def readyz():
    try:
        get_redis().ping()
    except RedisError as exc:
        return Response(f"redis unavailable: {exc}\n", status=503, mimetype="text/plain")
    return Response("ready\n", mimetype="text/plain")


@app.route("/metrics")
def metrics():
    if os.getenv("PROMETHEUS_MULTIPROC_DIR"):
        registry = CollectorRegistry()
        multiprocess.MultiProcessCollector(registry)
        return Response(generate_latest(registry), mimetype=CONTENT_TYPE_LATEST)
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True, threaded=True)
