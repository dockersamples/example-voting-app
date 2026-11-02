"""Gunicorn settings. Workers share Prometheus metrics via PROMETHEUS_MULTIPROC_DIR."""
import os

from prometheus_client import multiprocess

bind = "0.0.0.0:8080"
workers = int(os.getenv("GUNICORN_WORKERS", "4"))
keepalive = 2
graceful_timeout = 20  # finish in-flight requests on SIGTERM (rolling deploys)
accesslog = "-"
errorlog = "-"


def child_exit(server, worker):
    # Drop the dead worker's live gauges so /metrics stays accurate.
    multiprocess.mark_process_dead(worker.pid)
