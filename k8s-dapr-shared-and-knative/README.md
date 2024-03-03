# Installing the voting app with Dapr

The Dapr-ized version of the application uses the following projects
- Vote Service: [`java/vote`](../java/vote/)
- Worker Service: [`dotnet/worker`](../dotnet/worker/)
- Results Service: [`go/result`](../go/result/)

This version uses Dapr Shared and Knative Serving.

It also uses two statestores one for Votes (Redis) and one for the Results (PostgreSQL)

Create a new KinD Cluster

```
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 31080 # expose port 31380 of the node to port 80 on the host, later to be use by kourier or contour ingress
    listenAddress: 127.0.0.1
    hostPort: 80
EOF
```

Install Dapr: 

```
helm repo add dapr https://dapr.github.io/helm-charts/
helm repo update
helm upgrade --install dapr dapr/dapr \
--version=1.13.0-rc.10 \
--namespace dapr-system \
--create-namespace \
--wait
```


Then install Knative Serving (from [Official Docs](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/)): 

```
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-core.yaml
```

```
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.13.0/kourier.yaml
```

```
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
```

```
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.10.2/serving-default-domain.yaml

```

```
kubectl patch configmap -n knative-serving config-domain -p "{\"data\": {\"127.0.0.1.sslip.io\": \"\"}}"
```

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kourier-ingress
  namespace: kourier-system
  labels:
    networking.knative.dev/ingress-provider: kourier
spec:
  type: NodePort
  selector:
    app: 3scale-kourier-gateway
  ports:
    - name: http2
      nodePort: 31080
      port: 80
      targetPort: 8080
EOF
```

Install RabbitMQ by running the follwing: 

```
cd ..
cd k8s-platform/rabbitmq/
./deploy.sh
```

Now install the application, from the `k8s-dapr-shared-and-knative` directory: 
```
kubectl apply -f .
```


Finally, Now we need to create four instances of Dapr Shared, one for each service: 

```
helm install vote oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=vote --set shared.daprd.image.tag=1.13.0-rc.10
```

```
helm install result oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=result --set shared.daprd.image.tag=1.13.0-rc.10
```

```
helm install worker oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=worker --set shared.daprd.image.tag=1.13.0-rc.10
```

```
helm install echo oci://registry-1.docker.io/daprio/dapr-shared-chart --set shared.appId=echo --set shared.remoteURL=echo.default.svc.cluster.local --set shared.remotePort=80 --set shared.daprd.image.tag=1.13.0-rc.10
```


Once all the pods are up and running you can point your browser to the Knative Services:
```
kubectl get ksvc
```

You can point your browser to [http://vote.default.127.0.0.1.sslip.io](http://vote.default.127.0.0.1.sslip.io) to cast your vote. 

To see the results in real time you can point your browser to [http://result.default.127.0.0.1.sslip.io](http://result.default.127.0.0.1.sslip.io).

