### Chaos: `worker` down for 30s at 20 votes/s (fixed worker). Peak backlog: 576

| Measure | Result |
|---|---|
| Votes attempted | 1601 |
| Rejected (user saw an error) | 0 (0.0%) |
| Accepted (HTTP 200) | 1601 |
| Stored in Postgres | 1601 |
| Still queued in Redis | 0 |
| **Accepted but lost** | **0** |
| Vote service ready again after restart | 0s |
| p99 latency during run | 2.7 ms |
