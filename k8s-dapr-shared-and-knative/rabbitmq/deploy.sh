#!/bin/sh

set -euo pipefail

echo "\n🐰 RabbitMQ deployment started."

echo "\n📦 Installing RabbitMQ Cluster Kubernetes Operator..."

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/download/v2.7.0/cluster-operator-quay-io.yml"

echo "\n⌛ Waiting for RabbitMQ Operator to be deployed..."

while [ $(kubectl get pod -l app.kubernetes.io/name=rabbitmq-cluster-operator -n rabbitmq-system | wc -l) -eq 0 ] ; do
  sleep 15
done

echo "\n⌛ Waiting for RabbitMQ Operator to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=rabbitmq-cluster-operator \
  --timeout=300s \
  --namespace=rabbitmq-system

echo "\n ✅ The RabbitMQ Cluster Kubernetes Operator has been successfully installed."

echo "\n-----------------------------------------------------"

echo "\n📦 Deploying RabbitMQ cluster..."

kubectl apply -f resources/cluster.yml

echo "\n⌛ Waiting for RabbitMQ cluster to be deployed..."

while [ $(kubectl get pod -l app.kubernetes.io/name=rabbitmq | wc -l) -eq 0 ] ; do
  sleep 15
done

echo "\n⌛ Waiting for RabbitMQ cluster to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=rabbitmq \
  --timeout=600s

echo "\n✅ The RabbitMQ cluster has been successfully deployed."

echo "\n-----------------------------------------------------"

export RABBITMQ_USERNAME=$(kubectl get secret rabbitmq-default-user -o jsonpath='{.data.username}' | base64 --decode)
export RABBITMQ_PASSWORD=$(kubectl get secret rabbitmq-default-user -o jsonpath='{.data.password}' | base64 --decode)

echo "Username: $RABBITMQ_USERNAME"
echo "Password: $RABBITMQ_PASSWORD"

echo "\n🔑 Generating Secret with RabbitMQ credentials."

kubectl delete secret rabbitmq-credentials || true

kubectl create secret generic rabbitmq-credentials \
    --from-literal=username="$RABBITMQ_USERNAME" \
    --from-literal=password="$RABBITMQ_PASSWORD"

unset RABBITMQ_USERNAME
unset RABBITMQ_PASSWORD

echo "\n🍃 Secret 'rabbitmq-credentials' has been created for Dapr to interact with RabbitMQ."

echo "\n🐰 RabbitMQ deployment completed.\n"