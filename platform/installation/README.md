# Getting Started with the Kadras Engineering Platform

This guide describes how to install the Kadras Engineering Platform on a local Kubernetes cluster and on a cloud cluster.

## Cloud Installation

### 0. Before you begin

To follow the guide, ensure you have the following tools installed in your local environment:

* Kubernetes [`kubectl`](https://kubectl.docs.kubernetes.io/installation/kubectl)
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install)
* Carvel [`kapp`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl).

### 1. Deploy Carvel kapp-controller

The platform relies on the Kubernetes-native package management capabilities offered by Carvel [kapp-controller](https://carvel.dev/kapp-controller). You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

### 2. Add the Kadras Package Repository

Add the Kadras repository to make the platform packages available to the cluster.

  ```shell
  kctrl package repository add -r kadras-packages \
    --url ghcr.io/kadras-io/kadras-packages:0.18.0 \
    -n kadras-system --create-namespace
  ```

### 3. Configure the Platform

The installation of the Kadras Engineering Platform can be configured via YAML. A `values-cloud.yml` file is provided in the current folder with configuration to customize the cloud installation of the platform, based on the `run` installation profile. Make sure to update the domain names included in the YAML file with one of yours.

### 4. Install the Platform

Reference the `values-cloud.yml` file mentioned in the previous step and install the Kadras Engineering Platform.

  ```shell
  kctrl package install -i engineering-platform \
    -p engineering-platform.packages.kadras.io \
    -v 0.16.0 \
    -n kadras-system \
    --values-file values-cloud.yml
  ```

### 5. Verify the Installation

Verify that all the platform components have been installed and properly reconciled.

  ```shell
  kctrl package installed list -n kadras-system
  ```

A GitOps reconciliation strategy is used to install data services and applications. You can check the sync status as follows.

  ```shell
  kubectl get kustomization gitops-configurer -n kadras-system
  ```


### 6. Accessing Grafana

If you want to access Grafana, you can get the credentials from the dedicated Secret on the cluster.

```shell script
echo "Admin Username: $(kubectl get secret --namespace observability-stack loki-stack-grafana -o jsonpath="{.data.admin-user}" | base64 --decode)"
echo "Admin Password: $(kubectl get secret --namespace observability-stack loki-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)"
```

It will be available at [https://grafana.cloud.thomasvitale.dev](https://grafana.cloud.thomasvitale.dev).

### 7. Accessing RabbitMQ

The RabbitMQ management console is not publicly exposed, but you can access it via port forward at [http://localhost:15672](http://localhost:15672).

```shell script
kubectl port-forward svc/rabbitmq 15672:15672
```

You can get the credentials from the dedicated Secret.

```shell script
echo "Admin Username: $(kubectl get secret rabbitmq-default-user -o jsonpath='{.data.username}' | base64 --decode)"
echo "Admin Password: $(kubectl get secret rabbitmq-default-user -o jsonpath='{.data.password}' | base64 --decode)"
```

### 8. Testing the Applications

You can retrieve the URLs for each of the services using Knative:

```shell script
kubectl get ksvc
```

You can point your browser to [https://vote.default.cloud.kadras.io](https://vote.default.cloud.kadras.io) to cast your vote. 

To see the results in real time you can point your browser to [https://result.default.cloud.kadras.io](https://result.default.cloud.kadras.io).

## Local Installation

### 0. Before you begin

To follow the guide, ensure you have the following tools installed in your local environment:

* Kubernetes [`kubectl`](https://kubectl.docs.kubernetes.io/installation/kubectl)
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install)
* Carvel [`kapp`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl).

### 1. Create a local Kubernetes cluster

Create a local Kubernetes cluster with [kind](https://kind.sigs.k8s.io).

```shell
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kadras
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```

### 2. Deploy Carvel kapp-controller

The platform relies on the Kubernetes-native package management capabilities offered by Carvel [kapp-controller](https://carvel.dev/kapp-controller). You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

### 3. Add the Kadras Package Repository

Add the Kadras repository to make the platform packages available to the cluster.

  ```shell
  kctrl package repository add -r kadras-packages \
    --url ghcr.io/kadras-io/kadras-packages:0.18.0 \
    -n kadras-system --create-namespace
  ```

### 4. Configure the Platform

The installation of the Kadras Engineering Platform can be configured via YAML. A `values-local.yml` file is provided in the current folder with configuration to customize the local installation of the platform, based on the `run` installation profile.

The Ingress is configured with the special domain `127.0.0.1.sslip.io` which will resolve to your localhost and be accessible via the local cluster.

### 5. Install the Platform

Reference the `values-local.yml` file mentioned in the previous step and install the Kadras Engineering Platform.

  ```shell
  kctrl package install -i engineering-platform \
    -p engineering-platform.packages.kadras.io \
    -v 0.16.0 \
    -n kadras-system \
    --values-file values-local.yml
  ```

### 6. Verify the Installation

Verify that all the platform components have been installed and properly reconciled.

  ```shell
  kctrl package installed list -n kadras-system
  ```

### 7. Accessing Grafana

If you want to access Grafana, you can get the credentials from the dedicated Secret on the cluster.

```shell script
echo "Admin Username: $(kubectl get secret --namespace observability-stack loki-stack-grafana -o jsonpath="{.data.admin-user}" | base64 --decode)"
echo "Admin Password: $(kubectl get secret --namespace observability-stack loki-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)"
```

### 8. Testing the Applications

You can retrieve the URLs for each of the services using Knative:

```shell script
kubectl get ksvc
```

You can point your browser to [https://vote.default.127.0.0.1.sslip.io](http://vote.default.127.0.0.1.sslip.io) to cast your vote. 

To see the results in real time you can point your browser to [https://result.default.127.0.0.1.sslip.io](http://result.default.127.0.0.1.sslip.io).
