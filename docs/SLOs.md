# Service Level Objectives

The user journey that matters: **"I cast a vote and it gets counted."**
That has two halves, and the game day proved you need SLOs for both
(see [Game Day 001](gamedays/001-silent-backlog-and-lost-votes.md)).

| SLO | SLI (how it's measured) | Target | Window |
|---|---|---|---|
| **Availability** | Share of vote-service requests that return non-5xx (`vote_http_requests_total`) | 99.5% | 28 days |
| **Latency** | Share of requests served in < 300 ms (`vote_http_request_duration_seconds`, bucket `le="0.3"`) | 99% | 28 days |
| **Freshness** | Votes waiting in Redis for the worker (`redis_key_size{key="votes"}`) | < 100 queued | continuous |

Probe and scrape endpoints (`/healthz`, `/readyz`, `/metrics`) are excluded from
the SLIs so health checks can't inflate availability.

## Why these numbers

- **99.5%** leaves an error budget of ~3.4 hours of full outage per 28 days.
  That's enough room to deploy often and run chaos experiments, but low enough
  that a Redis outage of more than a few minutes shows up.
- **300 ms** is the point where a click stops feeling instant. The measured p99
  under a 200-user spike is 4.2 ms, so there's plenty of room. The SLO is set by
  what users notice, not by how fast the app happens to be today.
- **Freshness < 100 votes** means the results page is at most a few seconds
  behind at normal load. The availability and latency SLOs can't see this: during
  the spike test they were both perfect while 20,176 votes sat in the queue.

## Alerting: multi-window, multi-burn-rate

From the [Google SRE Workbook, ch. 5](https://sre.google/workbook/alerting-on-slos/).
Rules: [`observability/prometheus/rules/slo.yml`](../observability/prometheus/rules/slo.yml).
Unit tests: [`observability/prometheus/tests/slo_test.yml`](../observability/prometheus/tests/slo_test.yml).

| Alert | Condition | Meaning | Action |
|---|---|---|---|
| `VoteAvailabilityFastBurn` | error ratio > 14.4 × 0.5% over **1 h and 5 m** | 2% of the monthly budget gone in an hour | **Page** |
| `VoteAvailabilitySlowBurn` | error ratio > 6 × 0.5% over **6 h and 30 m** | 5% of budget gone in 6 hours | Ticket |
| `VoteLatencyFastBurn` | slow ratio > 14.4 × 1% over 1 h and 5 m | Latency budget burning fast | **Page** |
| `VoteBacklogGrowing` | backlog > 100 for 2 m | Votes accepted but not counted | **Page** |
| `VoteTargetDown` | `up{job="vote"} == 0` for 1 m | No metrics = flying blind | **Page** |

The long window makes sure the problem is real. The short window makes the
alert clear quickly once it's fixed. The promtool tests check both cases: a
sustained 10% error rate pages, and a 5-minute blip that has already recovered
does not.

## Error budget policy

- **Budget left:** ship freely, run chaos experiments.
- **Budget < 25%:** risky changes need a second reviewer, and chaos runs only in staging.
- **Budget spent:** freeze feature releases. Reliability fixes only until the
  28-day window recovers.
