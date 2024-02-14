# Installing the voting app with Dapr

The Dapr-ized version of the application uses the following projects
- Vote Service: `java/vote` ()
- Worker Service: `dotnet/worker`
- Results Service: `go/result`

It also uses two statestores one for Votes (Redis) and one for the Results (PostgreSQL)

Create a new KinD Cluster

```
kind create cluster
```

Install Dapr: 

```
helm repo add dapr https://dapr.github.io/helm-charts/
helm repo update
helm upgrade --install dapr dapr/dapr \
--version=1.12.3 \
--namespace dapr-system \
--create-namespace \
--wait
```

Now install the application, from the `k8s-dapr` directory: 
```
kubectl apply -f .
```

Once all the pods are up and running you can use `kubectl port-forward` to access the vote and result user interfaces.
In a new terminal run: 

```
kubectl port-forward svc/vote 4000:6000
```

In another terminal run: 

```
kubectl port-forward svc/result 3000:5001
```

You can point your browser to [http://localhost:4000](http://localhost:4000) to cast your vote. 

To see the results in real time you can point your browser to [http://localhost:3000](http://localhost:3000).

