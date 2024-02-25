# Deploying the Voting App with Carvel and Dapr

The Dapr-ized version of the application uses the following projects:

* Vote Service: [`java/vote`](../java/vote/)
* Worker Service: [`dotnet/worker`](../dotnet/worker/)
* Results Service: [`go/result`](../go/result/)

The deployment is based on a platform providing:

* Dapr
* Knative Serving
* Contour
* Cert Manager.

It also uses two State Stores: one for Votes (Redis) and one for Results (PostgreSQL).

## Prerequisites

### Local Installation

For a local installation, ensure you have the following tools installed in your local environment:

* [Podman](https://www.thomasvitale.com/podman-desktop-for-java-development) (or Docker)
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl)
* Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install)
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
  --url ghcr.io/kadras-io/kadras-packages:0.15.0 \
  -n kadras-packages --create-namespace
```

## Install the Platform

### Local Installation

Reference the `values-kind.yml` file available in the current folder and install the Kadras Engineering Platform.

```shell script
kctrl package install -i engineering-platform \
  -p engineering-platform.packages.kadras.io \
  -v 0.13.0 \
  -n kadras-packages \
  --values-file values-kind.yml
```

### Cloud Installation

_Coming soon_

## Verify the Installation

Verify that all the platform components have been installed and properly reconciled.

```shell script
kctrl package installed list -n kadras-packages
```

## Sidecar-less Dapr

Considering the serverless deployment strategy we want to use for the Voting application,
we'll configure Dapr to run as a DaemonSet rather than as a sidecar.

To achieve that, we need to install the Dapr Shared Helm Chart for each service:

```shell script
helm upgrade --install vote oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=vote --set shared.remoteURL=vote --set shared.remotePort=80   
helm upgrade --install result oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=result --set shared.remoteURL=result --set shared.remotePort=80   
helm upgrade --install worker oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=worker --set shared.daprd.image.tag=1.13.0-rc.2
```

Next, go ahead and install all application and data services composing the Voting system:

```shell script
kapp deploy -a voting-app -f app -y
```

Finally, you can retrieve the URLs for each of the services using Knative:

```shell script
kubectl get ksvc
```

You can point your browser to [https://vote.default.127.0.0.1.sslip.io](http://vote.default.127.0.0.1.sslip.io) to cast your vote. 

To see the results in real time you can point your browser to [https://result.default.127.0.0.1.sslip.io](http://result.default.127.0.0.1.sslip.io).

If you're running the system locally, you'll need to trust the self-signed certificate in the browser.
