#!/bin/sh

export RABBITMQ_USERNAME=$(kubectl get secret rabbitmq-default-user -o jsonpath='{.data.username}' | base64 --decode)
export RABBITMQ_PASSWORD=$(kubectl get secret rabbitmq-default-user -o jsonpath='{.data.password}' | base64 --decode)
export RABBITMQ_SERVICE=$(kubectl get service rabbitmq -o jsonpath='{.spec.clusterIP}')

kubectl run perf-test --image=pivotalrabbitmq/perf-test -- --uri amqp://$RABBITMQ_USERNAME:$RABBITMQ_PASSWORD@$RABBITMQ_SERVICE

unset RABBITMQ_USERNAME
unset RABBITMQ_PASSWORD
unset RABBITMQ_SERVICE