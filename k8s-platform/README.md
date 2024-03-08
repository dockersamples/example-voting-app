# Deploying the Voting App with Carvel and Dapr

The Dapr-ized version of the application uses the following projects:

* Echo Service: [`java/echo`](../java/echo/)
* Vote Service: [`java/vote`](../java/vote/)
* Worker Service: [`dotnet/worker`](../dotnet/worker/)
* Results Service: [`go/result`](../go/result/)

The deployment is based on a platform including:

* Dapr
* Knative Serving
* Contour
* Cert Manager
* RabbitMQ
* Redis
* PostgreSQL
* Grafana OSS.

It also uses two State Stores: one for Votes (Redis) and one for Results (PostgreSQL).

## Prerequisites

### Local Installation

For a local installation, ensure you have the following tools installed in your local environment:

* [Podman](https://www.thomasvitale.com/podman-desktop-for-java-development) (or Docker)
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl)
* Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install)
* [Helm](https://helm.sh/).
* [kind](https://kind.sigs.k8s.io).

Then, create a local Kubernetes cluster with `kind`.

```shell script
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

### Cloud Installation

For a cloud installation, ensure you have the following tools installed in your local environment:

* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl)
* Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install).

## Deploy Carvel kapp-controller

The platform relies on the Kubernetes-native package management capabilities offered by Carvel kapp-controller. You can install it with Carvel `kapp` (recommended choice) or `kubectl`.

```shell script
kapp deploy -a kapp-controller -y \
  -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

## Add the Kadras Repository

Add the Kadras repository to make the platform packages available to the cluster.

```shell script
kctrl package repository add -r kadras-packages \
  --url ghcr.io/kadras-io/kadras-packages:0.16.0 \
  -n kadras-packages --create-namespace
```

## Install the Platform

### Local Installation

Reference the `values-kind.yml` file available in the current folder and install the Kadras Engineering Platform.

```shell script
kctrl package install -i engineering-platform \
  -p engineering-platform.packages.kadras.io \
  -v 0.14.0 \
  -n kadras-packages \
  --values-file values-kind.yml
```

If you want to include observability, go ahead and deploy the Grafana observability platform.

```shell script
cd grafana
./deploy.sh
cd ..
```

Upon completing, the script will print the credentials you can use for logging into Grafana.

You can access the Grafana console via port-fowarding to your local machine:

```shell
kubectl port-forward --namespace observability-stack service/loki-stack-grafana 3000:80
```

Now, you can access Grafana at http://localhost:3000.

### Cloud Installation

_Coming soon_

## Applications and Sidecar-less Dapr

Let's deploy all the application and data services composing the Voting system:

```shell script
kubectl apply -f app
```

Considering the serverless deployment strategy we want to use for the Voting application,
we'll configure Dapr to run as a DaemonSet rather than as a sidecar (the default behaviour).

To achieve that, we need to install the Dapr Shared Helm Chart for each service:

```shell script
helm upgrade --install vote oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=vote --set shared.daprd.image.tag=1.13.0
helm upgrade --install result oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=result --set shared.daprd.image.tag=1.13.0
helm upgrade --install worker oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=worker --set shared.daprd.image.tag=1.13.0
helm install echo oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=echo --set shared.remoteURL=echo.default.svc.cluster.local --set shared.remotePort=80 --set shared.daprd.image.tag=1.13.0
```

Finally, you can retrieve the URLs for each of the services using Knative:

```shell script
kubectl get ksvc
```

You can point your browser to [https://vote.default.127.0.0.1.sslip.io](http://vote.default.127.0.0.1.sslip.io) to cast your vote. 

To see the results in real time you can point your browser to [https://result.default.127.0.0.1.sslip.io](http://result.default.127.0.0.1.sslip.io).

If you're running the system locally, you'll need to trust the self-signed certificate in the browser.
