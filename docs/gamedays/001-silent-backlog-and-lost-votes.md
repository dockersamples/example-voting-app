# Game Day 001: Green dashboards, lost votes

| | |
|---|---|
| **Date** | 2026-11-02 |
| **Format** | Planned chaos experiments + load tests, blameless write-up |
| **Environment** | Docker Compose (local), Prometheus + Grafana, k6 0.54 |
| **Status** | All four findings fixed and verified by re-running the same experiment |

## Summary

I load-tested and broke each dependency of the voting app on purpose. The HTTP
SLOs (availability and latency) **passed every load test**, including a spike to
200 concurrent users with p99 = 4.2 ms.

Underneath, the system was failing users in three ways the HTTP metrics could
not see:

1. **The worker could only process ~10 votes/s.** A 2-minute spike left
   **20,176 votes** waiting, and the results page was about 50 minutes behind.
2. **A database blip silently lost votes.** Votes the user had been told were
   accepted never reached Postgres.
3. **A Redis crash lost every queued vote.** In the test, that was 137 out of 137.

A fourth, smaller issue came from reading the code rather than from a run:
the upstream vote service doesn't handle Redis errors, so a Redis outage
becomes an unhandled HTTP 500. The old `docker-compose.yml` also ran Flask in
**debug mode** (`python app.py`), which serves an interactive debugger page.
Both were fixed before the experiments, so the Redis-outage numbers below show
clean 503s.

## Results: before vs after

Raw output for every run is in [`raw/`](raw/).

| Experiment | Before | After |
|---|---|---|
| Spike, 10 → 200 users: peak backlog | **20,176 votes** | **24 votes** |
| Spike: time for results to catch up | ~50 min | < 1 s |
| Postgres down 20 s at 50 votes/s: votes lost | **3** (plus 1,657 still queued after 2 min) | **0** (all 3,501 stored) |
| Postgres down 20 s at 5 votes/s: votes lost | 1 | 0 |
| Redis SIGKILL with 137 votes queued: votes lost | **137** | **0** |
| Redis down 20 s: what the user sees | Unhandled HTTP 500 (from code review, not measured) | HTTP 503 for 29% of votes during the outage, 0 accepted votes lost |
| Worker down 30 s at 20 votes/s | n/a | backlog peaked at 576, then drained; 1,601/1,601 stored |
| HTTP availability / p99 during spike | 100% / 4.2 ms | 100% / 4.2 ms |

## Timeline of discovery

| Step | What happened |
|---|---|
| Baseline load (ramp to 50 VUs, 4 min) | 18,250 requests, 0 failures, p99 3.3 ms. All SLO thresholds pass. |
| Spike (200 VUs) | 29,510 requests, 0 failures, p99 4.2 ms. **`VoteBacklogGrowing` fires.** Redis queue peaks at 20,176. |
| Investigated the worker | `Thread.Sleep(100)` after **every** vote → hard ceiling of ~10 votes/s, regardless of load. |
| Read the DB-reconnect path | The worker pops a vote, *then* checks whether the DB connection is open. If it isn't, it reconnects and **drops the popped vote.** |
| Postgres outage experiment | Confirmed: the worker crashed on `Connection is not open`, restarted, and the in-flight vote was gone. 3 lost at 50 votes/s. |
| Redis graceful restart | No loss. Redis writes a snapshot on SIGTERM. |
| Redis SIGKILL (realistic crash) | **All 137 queued votes lost.** Default persistence is RDB snapshots only, so a crash loses everything since the last one. |

## Root causes

### 1. The SLOs measured the wrong half of the journey
The user journey is *"my vote is counted"*, but every SLI measured the HTTP
front door. The vote service only puts votes on a queue, so it was healthy
while the part that actually counts votes was hours behind.

### 2. At-most-once delivery
`LPOP` removes a vote from Redis *before* it's written to Postgres. Anything
that fails between those two steps (crash, DB restart, network blip) loses the
vote for good, after the user was already told it succeeded.

### 3. Throughput cap hidden by a "be nice to the CPU" sleep
The 100 ms sleep was meant to stop busy-polling an *empty* queue, but it also
ran when the queue was full.

### 4. Redis treated as a cache but used as a queue
With no AOF, the "queue" was only as durable as the last snapshot.

## Fixes

| # | Fix | Where |
|---|---|---|
| 1 | Added a **freshness SLO** (backlog < 100) and a paging alert, with a promtool unit test that reproduces the spike | `observability/prometheus/rules/slo.yml`, `tests/slo_test.yml` |
| 2 | **At-least-once delivery:** `LMOVE votes → votes:processing`, write to Postgres, then `LREM`. In-flight votes are recovered on startup. Writes are idempotent upserts (`ON CONFLICT DO UPDATE`), so replays are safe | `worker/Program.cs` |
| 3 | Sleep **only when the queue is empty**. DB errors trigger a reconnect, not a crash | `worker/Program.cs` |
| 4 | Redis **AOF with `appendfsync everysec`** plus a persistent volume. A crash loses at most ~1 s | `docker-compose.yml`, `k8s/base/redis.yaml` |
| 5 | Vote service returns **503 instead of a 500 stack trace**. Liveness and readiness probes are split so a Redis outage removes pods from the load balancer instead of restarting them | `vote/app.py`, `k8s/base/vote.yaml` |
| 6 | **CI regression gate:** every PR runs the Postgres-outage experiment and fails if a single vote is lost | `.github/workflows/ci.yml` |

## What went well

- The backlog alert fired on the first spike. Measuring freshness at all is
  what exposed the problem.
- Turning each experiment into a script (`chaos/experiment.sh`) made
  "before" and "after" directly comparable, and made it possible to run in CI.

## Known limitations / follow-ups

- **One shared `votes:processing` list.** If one of several workers restarts,
  it moves *all* in-flight votes back to the queue, including ones another
  worker is still writing. Those votes get written twice, which is harmless
  because the upsert is idempotent, but each worker should have its own
  processing list (e.g. `votes:processing:<pod>`).
- **Redis is a single replica.** AOF protects against a crash, not against
  losing the node. Next step: Redis Sentinel, or a managed service
  (ElastiCache) with Multi-AZ.
- **No worker metrics.** The worker should export processed/failed counters
  and a per-vote end-to-end latency (enqueue → stored) so freshness can be
  measured in seconds, not queue length.
- **Lessons for any queue-backed system:** measure end-to-end freshness, not
  just the front door; acknowledge only after the write is durable; make
  writes idempotent so retries are safe.
