#!/usr/bin/env python3
"""Generate the Grafana SLO dashboard JSON. Usage: scripts/gen-dashboard.py observability/grafana/dashboards/vote-slo.json"""
import json, sys
DS = {"type": "prometheus", "uid": "prometheus"}
panels, pid = [], 0
def panel(title, exprs, x, y, w=8, h=8, kind="timeseries", unit=None, thresholds=None, desc=""):
    global pid; pid += 1
    p = {"id": pid, "type": kind, "title": title, "description": desc, "datasource": DS,
         "gridPos": {"x": x, "y": y, "w": w, "h": h},
         "targets": [{"refId": chr(65+i), "expr": e, "legendFormat": l, "datasource": DS} for i,(e,l) in enumerate(exprs)],
         "fieldConfig": {"defaults": {}, "overrides": []}, "options": {}}
    d = p["fieldConfig"]["defaults"]
    if unit: d["unit"] = unit
    if thresholds:
        d["thresholds"] = {"mode": "absolute", "steps": thresholds}
        if kind == "timeseries":
            d["custom"] = {"thresholdsStyle": {"mode": "line+area" if False else "line"}}
    if kind == "stat":
        p["options"] = {"colorMode": "background", "graphMode": "none", "reduceOptions": {"calcs": ["lastNotNull"]}}
    panels.append(p)
g = lambda c, v: {"color": c, "value": v}
# row 1: stats
panel("Availability (1h)", [("1 - vote:error_ratio:rate1h", "")], 0, 0, 6, 4, "stat", "percentunit",
      [g("red", None), g("orange", 0.99), g("green", 0.995)], "SLO target 99.5%")
panel("Requests < 300 ms (1h)", [("1 - vote:slow_ratio:rate1h", "")], 6, 0, 6, 4, "stat", "percentunit",
      [g("red", None), g("orange", 0.98), g("green", 0.99)], "SLO target 99%")
panel("Error budget burn rate (1h)", [("vote:error_ratio:rate1h / 0.005", "")], 12, 0, 6, 4, "stat", "x",
      [g("green", None), g("orange", 6), g("red", 14.4)], "1x = spending budget exactly on schedule. 14.4x pages.")
panel("Vote backlog (Redis)", [('sum(redis_key_size{key="votes"}) or vector(0)', "")], 18, 0, 6, 4, "stat", "short",
      [g("green", None), g("orange", 50), g("red", 100)], "Votes waiting for the worker. Freshness SLO: < 100")
# row 2
panel("Request rate by status", [('sum by (status) (rate(vote_http_requests_total[1m]))', "{{status}}")], 0, 4, 8, 8, unit="reqps")
panel("Error ratio vs SLO", [("vote:error_ratio:rate5m", "5m error ratio"), ("0.005", "SLO threshold (0.5%)")], 8, 4, 8, 8, unit="percentunit")
panel("Latency percentiles", [
    ("histogram_quantile(0.50, sum by (le) (rate(vote_http_request_duration_seconds_bucket[1m])))", "p50"),
    ("vote:latency_seconds:p95", "p95"), ("vote:latency_seconds:p99", "p99")], 16, 4, 8, 8, unit="s",
    thresholds=[g("green", None), g("red", 0.3)])
# row 3
panel("Vote backlog over time", [('redis_key_size{key="votes"}', "queued votes")], 0, 12, 8, 8, unit="short",
      thresholds=[g("green", None), g("red", 100)])
panel("Votes enqueued vs failed", [('sum by (option) (rate(vote_votes_total[1m]))', "option {{option}}"),
      ("sum(rate(vote_enqueue_failures_total[1m]))", "enqueue failures")], 8, 12, 8, 8, unit="reqps")
panel("Firing alerts", [('ALERTS{alertstate="firing"}', "{{alertname}} ({{severity}})")], 16, 12, 8, 8, unit="short")
dash = {"uid": "vote-slo", "title": "Voting App: SLOs & Golden Signals", "tags": ["sre", "slo"],
        "timezone": "browser", "schemaVersion": 39, "version": 1, "refresh": "5s",
        "time": {"from": "now-15m", "to": "now"}, "panels": panels}
json.dump(dash, open(sys.argv[1], "w"), indent=2)
