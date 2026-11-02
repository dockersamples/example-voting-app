# Voting App SRE: common tasks.  `make help` lists them.
COMPOSE ?= docker compose
K6 = $(COMPOSE) --profile loadtest run --rm
PROMTOOL = docker run --rm --entrypoint promtool -v $(CURDIR)/observability/prometheus:/p prom/prometheus:v2.55.1

.PHONY: help up down logs test smoke load spike chaos-redis chaos-db chaos-worker check-rules test-rules k8s-render k8s-up k8s-down

help: ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

up: ## Build and start app + Prometheus + Grafana
	$(COMPOSE) up -d --build
	@echo "vote:       http://localhost:5000"
	@echo "result:     http://localhost:5001"
	@echo "grafana:    http://localhost:3000  (dashboard: Voting App: SLOs & Golden Signals)"
	@echo "prometheus: http://localhost:9090/alerts"

down: ## Stop everything and delete volumes
	$(COMPOSE) down -v

logs: ## Tail app logs
	$(COMPOSE) logs -f vote worker

test: test-rules ## Unit tests (vote service + alert rules)
	cd vote && python -m pytest -q tests

smoke: ## k6 smoke test (CI gate, 30 s)
	$(K6) -e PROFILE=smoke k6 run /scripts/vote.js

load: ## k6 load test: ramp to 50 VUs (~4 min)
	$(K6) -e PROFILE=load k6 run /scripts/vote.js

spike: ## k6 spike test: 10 -> 200 VUs
	$(K6) -e PROFILE=spike k6 run /scripts/vote.js

chaos-redis: ## Stop Redis for 20 s under load, measure impact
	COMPOSE="$(COMPOSE)" chaos/experiment.sh redis 20 5

chaos-db: ## Stop Postgres for 20 s under 50 votes/s, measure data loss
	COMPOSE="$(COMPOSE)" chaos/experiment.sh db 20 50

chaos-worker: ## Stop the worker for 20 s, watch backlog + freshness alert
	COMPOSE="$(COMPOSE)" chaos/experiment.sh worker 20 5

check-rules: ## Validate Prometheus rules and check the k8s copy is in sync
	$(PROMTOOL) check rules /p/rules/slo.yml
	python scripts/gen-k8s-monitoring.py
	git diff --exit-code k8s/monitoring/prometheusrule.yaml

test-rules: ## Unit-test alert rules with promtool
	$(PROMTOOL) test rules /p/tests/slo_test.yml

k8s-render: ## Render Kubernetes manifests
	kubectl kustomize k8s/base

k8s-up: ## Create a kind cluster, build images and deploy
	kind create cluster --name voting-app --config k8s/kind.yaml || true
	for s in vote worker result; do docker build -t voting-app/$$s:dev ./$$s && kind load docker-image voting-app/$$s:dev --name voting-app; done
	kubectl apply -k k8s/base
	kubectl -n voting-app rollout status deploy/vote deploy/worker deploy/result --timeout=180s
	@echo "vote: http://localhost:31000   result: http://localhost:31001"

k8s-down: ## Delete the kind cluster
	kind delete cluster --name voting-app
