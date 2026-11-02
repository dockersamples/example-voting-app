### Chaos: `db` down for 20s at 5 votes/s

| Measure | Result |
|---|---|
| Votes attempted | 350 |
| Rejected (user saw an error) | 0 (0.0%) |
| Accepted (HTTP 200) | 350 |
| Stored in Postgres | 350 |
| Still queued in Redis | 0 |
| **Accepted but lost** | **0** |
| Vote service ready again after restart | 0s |
| p99 latency during run | 3.4 ms |
