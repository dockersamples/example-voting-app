# Runbook: VoteBacklogGrowing

**What it means:** more than 100 votes have been waiting in Redis for over
2 minutes. Users were told their vote succeeded, but the results page doesn't
show it yet.

**Why it matters:** the HTTP SLOs can be 100% green while this fires. That's
exactly what happened in [Game Day 001](../gamedays/001-silent-backlog-and-lost-votes.md).

## 1. Is the worker running?

```bash
kubectl -n voting-app get pods -l app=worker
kubectl -n voting-app logs deploy/worker --tail=50
```

- `Waiting for db` / `Database error, reconnecting` → Postgres problem, go to step 2.
- `Waiting for redis` → Redis problem, see the high error rate runbook.
- Pods `CrashLoopBackOff` → `kubectl -n voting-app rollout undo deploy/worker`.

## 2. Is Postgres healthy?

```bash
kubectl -n voting-app exec statefulset/db -- pg_isready -U postgres
kubectl -n voting-app exec statefulset/db -- psql -U postgres -c "select count(*) from votes"
```

## 3. Worker healthy but backlog still growing? Scale out.

Votes are claimed atomically (`LMOVE`) and writes are idempotent, so more
workers are safe:

```bash
kubectl -n voting-app scale deploy/worker --replicas=4
```

Watch **Vote backlog over time** in Grafana. It should fall within minutes.

## 4. Check for stuck in-flight votes

```bash
kubectl -n voting-app exec statefulset/redis -c redis -- redis-cli LLEN votes:processing
```

A non-zero value that doesn't change means a worker died while holding votes.
They're returned to the queue automatically when any worker restarts:
`kubectl -n voting-app rollout restart deploy/worker`.
