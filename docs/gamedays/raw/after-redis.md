### Chaos: `redis` down for 20s at 5 votes/s

| Measure | Result |
|---|---|
| Votes attempted | 351 |
| Rejected (user saw an error) | 102 (29.1%) |
| Accepted (HTTP 200) | 249 |
| Stored in Postgres | 249 |
| Still queued in Redis | 0 |
| **Accepted but lost** | **0** |
| Vote service ready again after restart | 0s |
| p99 latency during run | 3.0 ms |
