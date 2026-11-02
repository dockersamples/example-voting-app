# Runbook: VoteAvailabilityFastBurn / SlowBurn

**What it means:** too many vote requests are failing (5xx). At fast-burn rates
the 28-day error budget runs out in under 2 days.

**User impact:** people click a button and get "Vote service temporarily
unavailable." Their vote is **not** recorded, but they are told so. (A 503 is
honest; a silent loss is worse. See Game Day 001.)

## 1. Confirm (2 min)

- Grafana → *Voting App: SLOs & Golden Signals* → **Request rate by status**
  and **Error ratio vs SLO**.
- Is it all requests, or only `POST /`? Only POST almost always means Redis.

```bash
kubectl -n voting-app get pods -o wide
kubectl -n voting-app exec deploy/vote -- python -c "import urllib.request;print(urllib.request.urlopen('http://localhost:8080/readyz').read())"
```

## 2. Most likely causes

| Signal | Likely cause | Fix |
|---|---|---|
| `/readyz` says `redis unavailable`, `vote_enqueue_failures_total` rising | Redis down or unreachable | `kubectl -n voting-app get pods -l app=redis`, check events, PVC, OOMKilled. Restart: `kubectl -n voting-app rollout restart statefulset/redis` |
| Vote pods restarting | Bad deploy, OOM | `kubectl -n voting-app rollout undo deploy/vote` |
| All pods NotReady, Redis fine | NetworkPolicy / DNS change | `kubectl -n voting-app exec deploy/vote -- getent hosts redis` |

## 3. Mitigate first, investigate second

Roll back the last change if there was one in the past hour:
`kubectl -n voting-app rollout undo deploy/vote`.

## 4. After

Write a blameless postmortem if more than 5% of the budget was spent.
Template: [Game Day 001](../gamedays/001-silent-backlog-and-lost-votes.md).
