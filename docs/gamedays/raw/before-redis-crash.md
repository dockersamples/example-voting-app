### Chaos: `redis` SIGKILL with 137 votes queued (worker stopped)

| Measure | Result |
|---|---|
| Votes accepted (HTTP 200) and queued | 137 |
| Queued after Redis restart | 0 |
| **Accepted but lost** | **137** |

Graceful restart (SIGTERM) kept all 200 queued votes because Redis writes an
RDB snapshot on shutdown. A crash loses everything since the last snapshot
(default `save 3600 1 300 100 60 10000`), i.e. up to an hour of votes.
