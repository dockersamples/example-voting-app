#!/usr/bin/env bash
# Chaos experiment: take one dependency down under steady load and measure
# the user-facing impact, recovery time and data integrity.
#
#   chaos/experiment.sh <service> [outage_seconds] [votes_per_second]
#   e.g. chaos/experiment.sh redis 20 5
#
# Prints a markdown result block; also saved to results/chaos-<service>.md
set -euo pipefail

TARGET="${1:?usage: experiment.sh <redis|db|worker> [outage_s] [rate]}"
OUTAGE="${2:-20}"
RATE="${3:-5}"
WARMUP=20
DURATION=$((WARMUP + OUTAGE + 30))
COMPOSE="${COMPOSE:-docker compose}"
OUT="results/chaos-${TARGET}.md"

psql() { $COMPOSE exec -T db psql -U postgres -tAc "$1"; }

echo ">> resetting state"
$COMPOSE exec -T redis redis-cli DEL votes >/dev/null
psql "TRUNCATE votes" >/dev/null 2>&1 || true

echo ">> starting k6: ${RATE} votes/s for ${DURATION}s"
$COMPOSE --profile loadtest run --rm -T \
  -e PROFILE=steady -e RATE="$RATE" -e DURATION="${DURATION}s" -e RUN_NAME="chaos-${TARGET}" \
  k6 run --quiet /scripts/vote.js > "results/k6-chaos-${TARGET}.log" 2>&1 &
K6_PID=$!

sleep "$WARMUP"
echo ">> injecting failure: stopping ${TARGET} for ${OUTAGE}s"
T0=$(date +%s)
$COMPOSE stop "$TARGET" >/dev/null 2>&1
sleep "$OUTAGE"
$COMPOSE start "$TARGET" >/dev/null 2>&1
T1=$(date +%s)

# Time until the vote service reports ready again (it depends on Redis).
until curl -fs localhost:5000/readyz >/dev/null 2>&1; do sleep 0.5; done
T2=$(date +%s)

wait "$K6_PID" || true   # k6 exits non-zero when thresholds fail; that's data, not an error

echo ">> waiting for the worker to drain the backlog"
for _ in $(seq 1 120); do
  [ "$($COMPOSE exec -T redis redis-cli LLEN votes)" = "0" ] && break
  sleep 1
done
sleep 3

SUMMARY="results/k6-chaos-${TARGET}-summary.json"
read -r ACCEPTED REJECTED P99 <<<"$(python3 - "$SUMMARY" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
checks = {c["name"]: c for c in d["root_group"]["checks"]}
v = checks["vote accepted"]
print(v["passes"], v["fails"], round(d["metrics"]["http_req_duration"]["values"]["p(99)"], 1))
PY
)"
STORED=$(psql "SELECT count(*) FROM votes")
BACKLOG=$($COMPOSE exec -T redis redis-cli LLEN votes)
LOST=$((ACCEPTED - STORED - BACKLOG))
TOTAL=$((ACCEPTED + REJECTED))

cat > "$OUT" <<MD
### Chaos: \`${TARGET}\` down for ${OUTAGE}s at ${RATE} votes/s

| Measure | Result |
|---|---|
| Votes attempted | ${TOTAL} |
| Rejected (user saw an error) | ${REJECTED} ($(python3 -c "print(f'{${REJECTED}/max(${TOTAL},1):.1%}')")) |
| Accepted (HTTP 200) | ${ACCEPTED} |
| Stored in Postgres | ${STORED} |
| Still queued in Redis | ${BACKLOG} |
| **Accepted but lost** | **${LOST}** |
| Vote service ready again after restart | $((T2 - T1))s |
| p99 latency during run | ${P99} ms |
MD
cat "$OUT"
