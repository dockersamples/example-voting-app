"""Unit tests for the vote service's reliability behaviour (no Redis needed)."""
import os
import sys
from pathlib import Path
from unittest import mock

import pytest
from redis.exceptions import ConnectionError as RedisConnectionError

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
os.environ.pop("PROMETHEUS_MULTIPROC_DIR", None)

import app as vote_app  # noqa: E402


@pytest.fixture
def client():
    vote_app.app.config["TESTING"] = True
    with vote_app.app.test_client() as c:
        yield c


def _redis(ok=True):
    fake = mock.MagicMock()
    if not ok:
        fake.rpush.side_effect = RedisConnectionError("down")
        fake.ping.side_effect = RedisConnectionError("down")
    return fake


def test_get_renders_page(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert b"Cats" in resp.data


def test_vote_is_enqueued(client):
    fake = _redis()
    with mock.patch.object(vote_app, "Redis", return_value=fake):
        resp = client.post("/", data={"vote": "a"})
    assert resp.status_code == 200
    fake.rpush.assert_called_once()


def test_invalid_vote_rejected(client):
    resp = client.post("/", data={"vote": "zzz"})
    assert resp.status_code == 400


def test_redis_down_returns_503_not_500(client):
    with mock.patch.object(vote_app, "Redis", return_value=_redis(ok=False)):
        resp = client.post("/", data={"vote": "b"})
    assert resp.status_code == 503


def test_liveness_ignores_redis(client):
    with mock.patch.object(vote_app, "Redis", return_value=_redis(ok=False)):
        assert client.get("/healthz").status_code == 200


def test_readiness_fails_when_redis_down(client):
    with mock.patch.object(vote_app, "Redis", return_value=_redis(ok=False)):
        assert client.get("/readyz").status_code == 503


def test_metrics_exposed_and_probes_excluded(client):
    client.get("/")
    client.get("/healthz")
    body = client.get("/metrics").data.decode()
    assert "vote_http_request_duration_seconds_bucket" in body
    assert 'route="/healthz"' not in body
