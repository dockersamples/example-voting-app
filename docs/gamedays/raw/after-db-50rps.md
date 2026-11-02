### Chaos: `db` down for 20s at 50 votes/s (fixed worker)

| Measure | Result |
|---|---|
| Votes attempted | 3501 |
| Rejected (user saw an error) | 0 (0.0%) |
| Accepted (HTTP 200) | 3501 |
| Stored in Postgres | 3501 |
| Still queued in Redis | 0 |
| **Accepted but lost** | **0** |
| Vote service ready again after restart | 0s |
| p99 latency during run | 2.8 ms |
