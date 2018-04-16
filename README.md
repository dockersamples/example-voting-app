Setting up Example Voting App in Codefresh
=========
[![Codefresh build status]( https://g.codefresh.io/api/badges/build?repoOwner=codefresh-io&repoName=example-voting-app&branch=master&pipelineName=example-voting-app-matrix&accountName=perfect_pipeline&type=cf-1)]( https://g.codefresh.io/repositories/codefresh-io/example-voting-app/builds?filter=trigger:build;branch:master;service:5a84d1002b8eaa0001568329~example-voting-app-matrix)

What are we doing?

We are deploying the Docker example voting app as a Helm Release using Codefresh.

(3) - result, vote and worker micro-services

We will show you how to:
* Add a repository to Codefresh.
* Create a matrix pipeline to build (3) micro-services in parallel.
* Deploy the Docker example voting app to your Kubernetes cluster using Codefresh + Helm.
* The Helm chart uses a combination of local-charts for (3) and community charts for Redis and Postgres.

Now onto the How-to!

Creating Codefresh pipelines
--------------

PreReqs:

* [Codefresh Account](https://g.codefresh.io/signup)
* [Kubernetes cluster](https://kubernetes.io/)

Some popular Kubernetes options

* [Amazon KOPs](https://github.com/kubernetes/kops) [Tutorial](https://codefresh.io/kubernetes-tutorial/tutorial-deploying-kubernetes-to-aws-using-kops/)
* [Amazon EKS (Preview)](https://aws.amazon.com/eks/)
* [Azure Container Service (Moving to AKS)](https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-walkthrough)
* [Azure Kubernetes Service (Preview)](https://docs.microsoft.com/en-us/azure/aks/) [Webinar](https://codefresh.io/webinars/devops_kubernetes_helm/)
* [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/) [Tutorial](https://codefresh.io/kubernetes-tutorial/get-first-app-running-kubernetes-codefresh-google-container-engine/)
* [IBM Cloud Container Service](https://www.ibm.com/cloud/container-service)
* [Stackpoint Cloud](https://stackpoint.io/)

Fork this [Github Repository](https://github.com/codefresh-io/example-voting-app)
----
Either [Fork](https://help.github.com/articles/fork-a-repo/) or copy this repositories content to your Github Account or a GIT repository in another Version Control System.

[Attach Kubernetes Cluster to Codefresh](https://codefresh.io/docs/docs/deploy-to-kubernetes/adding-non-gke-kubernetes-cluster/)
----

You'll need to configure your Kubernetes cluster in Codefresh.  See link above.

Setup Docker Registry Pull Secret in Kubernetes
----

If you'd like to add your own Docker Registry

[Add Docker Registry to Codefresh](https://codefresh.io/docs/docs/docker-registries/external-docker-registries/)

If you want to us Codefresh Integrated Docker Registry

[Generate CFCR Login Token](https://codefresh.io/docs/docs/docker-registries/codefresh-registry/#generate-cfcr-login-token)

Example commands below use cfcr (Codefresh Integrated Registry).  Update if you decide to use your own Docker Registry

[Configure Kubernetes namespace with Pull Secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

Command to create Pull Secret

``` sh
kubectl create secret docker-registry -n <kubenetes_namespace> cfcr  --docker-server=r.cfcr.io --docker-username=<codefresh_username>  --docker-password=<cfcr_token> --docker-email=<codefresh_email>
```

Command to patch Service Account with Pull Secret

``` sh
kubectl patch <service_account_name> <kubernetes_namespace> -p "{\"imagePullSecrets\": [{\"name\": \"cfcr\"}]}" -n <kubernetes_namespace>
```

Create [Codefresh CLI](https://codefresh-io.github.io/cli/getting-started/) Key
----

1. Create [API key in Codefresh](https://g.codefresh.io/account/tokens)
1. Click GENERATE button.
1. Copy key to safe location for later use in `CODEFRESH_CLI_KEY` variable.

Update YAML files
----

If you decided not use `cfcr` as your Docker Registry then you can skip this step.

Edit the Codefresh YAML in `./result`, `./vote` and `./worker` directories with your friendly Docker registry name for registry in YAML.

Create Codefresh pipelines
----

In Codefresh add a new Repository and select `example-voting-app`

1. Click Add New Repository button from Repositories screen.
1. Select the example-voting-app repository you forked or clone to your VCS/Organization. (master branch if fine) Then click NEXT button.
1. Click SELECT for CODEFRESH.YML option.
1. Update PATH TO CODEFRESH.YML with `./codefresh-matrix-pipeline.yml`. Then click NEXT button.
1. Review Codefresh YAML. Then click CREATE button.
1. Click CREATE_PIPELINE button.

You'll arrive at the `example-voting-app` pipeline.

Now we need to configure some Environment Variables for the Repository.

1. Click on General tab in the `example-voting-app` Repository page.
1. Add the following variables below. (Encrypt the sensitive variables). Click ADD VARIABLE link after every variable to add.
1. `CODEFRESH_ACCOUNT` Your Codefresh Account Name (shown in lower left of Codefresh UI). If you chose to use CFCR
1. `CODEFRESH_CLI_KEY` Your [Codefresh CLI](https://codefresh-io.github.io/cli/getting-started/) [Key](https://g.codefresh.io/account/tokens) ENCRYPT.
1. `KUBE_CONTEXT` Your friendly [Kubernetes Cluster Name](https://g.codefresh.io/account/integration/kubernetes) to use for release.
1. `KUBE_NAMESPACE` Kubernetes namespace to use for release.
1. `KUBE_PULL_SECRET` Kubernetes Pull Secret name.

The matrix pipeline is already configured and named after your GIT repository `example-voting-app`.

We need to setup the following (3) pipelines.
From Pipelines page of `example-voting-app` repository.
1. Click ADD PIPELINE (do this 3 times)
1. Name `example-voting-app1` to `example-voting-app-result`; Set WORKFLOW to YAML, Set Use YAML from Repository; Edit PATH_TO_YAML `./result/codefresh-result-pipeline.yml`; Click SAVE button at bottom of page.
1. Name `example-voting-app2` to `example-voting-app-vote`; Set WORKFLOW to YAML, Set Use YAML from Repository; Edit PATH_TO_YAML `./vote/codefresh-vote-pipeline.yml`; Click SAVE button at bottom of page.
1. Name `example-voting-app3` to `example-voting-app-worker`; Set WORKFLOW to YAML, Set Use YAML from Repository; Edit PATH_TO_YAML `./worker/codefresh-worker-pipeline.yml`; Click SAVE button at bottom of page.

Now we need to get your Codefresh Pipeline IDs to setup parallel builds.

Two options:
* CLI
1. `codefresh get pipelines`

* UI
1. Open Repository.
1. Click on each pipeline.
1. Expand General Settings.
1. Tempoary toggle on Webhook.
1. Capture ID from the curl command shown.

Record your Pipeline IDs

1. Open your `example-voting-app` Codefresh pipeline.
1. Add the following environment variable.
`PARALLEL_PIPELINES_IDS` with space delimited Codefresh Pipeline IDs.
1. Click ADD VARIABLE link below variable listing.
1. Click SAVE button at bottom of page.

Now you can run your example-voting-app pipeline to produce a Helm Release.

When the build is finished you will see a new Helm Release for [example-voting-app](https://g.codefresh.io/helm/releases/releases/?filter=search:example-voting-app)

[![Codefresh Helm Release Status]( https://g.codefresh.io/api/badges/release?type=cf-1&key=eyJhbGciOiJIUzI1NiJ9.NWE4NGNiNzQ1ODhjZjQwMDAxNDA0YzU2.ThdF7iizUJnusHWxZpbwLApHZDvr5uD_eZvem_fB3ho&selector=perfect-pipeline@FirstKubernetes&name=example-voting-app&tillerNamespace=kube-system)]( https://g.codefresh.io/helm/releases/perfect-pipeline@FirstKubernetes/default/example-voting-app/services)

Hopefully this has given you a somewhat overall picture of setting up Codefresh to run a Kubernetes deployment utilizing Helm.

Now you can play with the release or do something similar with your own application.

Notes
----

We'll be adding a Blog Post and additional followups to this example. Ex. Unit Tests, Integration Tests, Security Tests and Functional Testing.

If you'd like to schedule a demo of Codefresh to get help adding your own CI/CD steps to your Codefresh Pipelines [Click Here](https://codefresh.io/request-a-demo/)

ORIGINAL CONTENT BELOW, PLEASE NOTE DOCKER COMPOSE DOES NOT WORK AT THIS TIME.

Example Voting App
=========

Getting started
---------------

Download [Docker](https://www.docker.com/products/overview). If you are on Mac or Windows, [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/). If you're using [Docker for Windows](https://docs.docker.com/docker-for-windows/) on Windows 10 pro or later, you must also [switch to Linux containers](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers).

Run in this directory:
```
docker-compose up
```
The app will be running at [http://localhost:5000](http://localhost:5000), and the results will be at [http://localhost:5001](http://localhost:5001).

Alternately, if you want to run it on a [Docker Swarm](https://docs.docker.com/engine/swarm/), first make sure you have a swarm. If you don't, run:
```
docker swarm init
```
Once you have your swarm, in this directory run:
```
docker stack deploy --compose-file docker-stack.yml vote
```

Architecture
-----

![Architecture diagram](architecture.png)

* A Python webapp which lets you vote between two options
* A Redis queue which collects new votes
* A .NET worker which consumes votes and stores them in…
* A Postgres database backed by a Docker volume
* A Node.js webapp which shows the results of the voting in real time


Note
----

The voting application only accepts one vote per client. It does not register votes if a vote has already been submitted from a client.