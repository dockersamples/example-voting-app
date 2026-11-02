### Chaos: `db` down for 20s at 50 votes/s (original upstream worker)

| Measure | Result |
|---|---|
| Votes attempted | 3501 |
| Rejected (user saw an error) | 0 (0.0%) |
| Accepted (HTTP 200) | 3501 |
| Stored in Postgres | 1841 |
| Still queued in Redis | 1657 |
| **Accepted but lost** | **3** |
| Vote service ready again after restart | 0s |
| p99 latency during run | 2.7 ms |
