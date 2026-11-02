### Spike test (10 -> 200 VUs): HTTP SLOs vs freshness

| Measure | Result |
|---|---|
| Requests | 29,510 (209.8/s) |
| Failed | 0.000% |
| p95 / p99 latency | 2.7 / 4.2 ms |
| **Peak vote backlog in Redis** | **20,176** |
| Drain rate after the spike | ~6.6 votes/s |
| Time for results page to catch up | ~50 min |

Every HTTP SLO passed. `VoteBacklogGrowing` fired.
