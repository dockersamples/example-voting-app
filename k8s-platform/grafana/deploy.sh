#!/bin/sh

set -euo pipefail

echo "\n🔭  Observability stack deployment started.\n"

kubectl apply -f resources/namespace.yml

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "\n📦 Installing Tempo..."

helm upgrade --install tempo --namespace=observability-stack grafana/tempo \
  --values helm/tempo-values.yml

echo "\n⌛ Waiting for Tempo to be ready..."

while [ $(kubectl get pod -l app.kubernetes.io/name=tempo -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=tempo \
  --timeout=90s \
  --namespace=observability-stack

echo "\n📦 Installing Grafana, Loki, Prometheus, and Promtail..."

kubectl apply -f resources/dashboards

helm upgrade --install loki-stack --namespace=observability-stack grafana/loki-stack \
  --values helm/loki-stack-values.yml

sleep 5

echo "\n⌛ Waiting for Promatail to be ready..."

while [ $(kubectl get pod -l app.kubernetes.io/name=promtail -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=promtail \
  --timeout=90s \
  --namespace=observability-stack

echo "\n⌛ Waiting for Prometheus to be ready..."

while [ $(kubectl get pod -l app=prometheus -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app=prometheus \
  --timeout=90s \
  --namespace=observability-stack

echo "\n⌛ Waiting for Loki to be ready..."

while [ $(kubectl get pod -l app=loki -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app=loki \
  --timeout=90s \
  --namespace=observability-stack

echo "\n⌛ Waiting for Grafana to be ready..."

while [ $(kubectl get pod -l app.kubernetes.io/name=grafana -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=grafana \
  --timeout=90s \
  --namespace=observability-stack

echo "\n✅  Grafana observability stack has been successfully deployed."

echo "\n🔐 Your Grafana admin credentials...\n"

echo "Admin Username: $(kubectl get secret --namespace observability-stack loki-stack-grafana -o jsonpath="{.data.admin-user}" | base64 --decode)"
echo "Admin Password: $(kubectl get secret --namespace observability-stack loki-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)"

echo "\n🔭  Observability stack deployment completed.\n"
