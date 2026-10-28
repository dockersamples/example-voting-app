
# Example Voting App — DevOps Capstone

A distributed voting application used to demonstrate containerization, container security, continuous integration and delivery (CI/CD), Kubernetes orchestration, infrastructure as code (IaC), and Helm-based release management.

This project extends the Example Voting App with container hardening, Kubernetes security controls, persistent database storage, automated vulnerability scanning, image publishing, Terraform infrastructure configuration, and a Helm chart.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Run Locally with Docker Compose](#run-locally-with-docker-compose)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Container Security](#container-security)
- [CI/CD Pipeline](#cicd-pipeline)
- [Terraform Infrastructure](#terraform-infrastructure)
- [Helm Chart](#helm-chart)
- [Testing and Validation](#testing-and-validation)
- [Repository Structure](#repository-structure)
- [Security Considerations](#security-considerations)
- [Project Status](#project-status)
- [Future Improvements](#future-improvements)

## Project Overview

The Example Voting App is a distributed application that allows users to submit votes and view the results.

The application consists of five main services:

1. **Vote:** A Python web application that accepts votes.
2. **Redis:** A message queue that temporarily stores incoming votes.
3. **Worker:** A .NET application that processes votes from Redis.
4. **PostgreSQL:** A relational database that stores voting results.
5. **Result:** A Node.js web application that displays the results.

The purpose of this capstone is to demonstrate how a containerized application can be built, secured, tested, scanned for vulnerabilities, deployed to Kubernetes, and managed through infrastructure as code and Helm.

## Architecture

![Example Voting App Architecture](architecture.excalidraw.png)

### Application flow

1. A user submits a vote through the Vote web application.
2. Redis temporarily stores the vote.
3. The Worker service processes the vote.
4. PostgreSQL stores the processed voting data.
5. The Result web application displays the voting results.

The services communicate over the container network or Kubernetes services, depending on the deployment environment.

## Technologies Used

| Technology | Purpose |
|---|---|
| Docker | Containerization |
| Docker Compose | Local multi-container orchestration |
| Kubernetes | Container orchestration |
| Terraform | Infrastructure as code |
| Azure Virtual Network | Azure network infrastructure |
| Azure Kubernetes Service (AKS) | Target managed Kubernetes platform |
| Helm | Kubernetes application packaging and release management |
| GitHub Actions | CI/CD automation |
| Trivy | Container vulnerability scanning |
| GitHub Container Registry (GHCR) | Container image publishing |
| Python | Vote application |
| Redis | Vote message queue |
| .NET | Vote processing worker |
| PostgreSQL | Persistent voting data |
| Node.js | Results application |

## Prerequisites

To work with the project locally, install:

- Docker Desktop or Docker Engine.
- Docker Compose.
- `kubectl` for Kubernetes operations.
- Helm for chart validation and deployment.
- Terraform for infrastructure configuration.
- Azure CLI for Azure authentication and resource management.
- An Azure subscription with the required permissions and sufficient budget if provisioning AKS.

## Run Locally with Docker Compose

### 1. Start the application

From the repository root, run:

```bash
docker compose up -d --build
```

### 2. Verify the containers

```bash
docker compose ps
```

### 3. Access the application

- Voting interface: http://localhost:8080
- Results interface: http://localhost:8081

Submit a vote through the voting interface and check the results page.

### 4. Stop the application

```bash
docker compose down
```

To remove the containers and network, use the command above. Persistent data may remain in Docker volumes unless those volumes are explicitly removed.

## Kubernetes Deployment

The `k8s-specifications/` directory contains the Kubernetes manifests for the application services, deployments, services, and PostgreSQL persistent storage.

### 1. Check the active cluster

```bash
kubectl config current-context
kubectl get nodes
```

Ensure that `kubectl` is pointing to the intended cluster before applying resources.

### 2. Create the database credentials Secret

The application expects a Kubernetes Secret named `db-credentials` containing these keys:

- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_DB`

For a local demonstration environment, the Secret can be created using:

```bash
kubectl create secret generic db-credentials \
  --from-literal=POSTGRES_USER=postgres \
  --from-literal=POSTGRES_PASSWORD=postgres \
  --from-literal=POSTGRES_DB=postgres
```

If the Secret already exists, update it using an appropriate secure method rather than creating a duplicate.

**Security warning:** The example credentials above are for demonstration only. Do not use default credentials in production. Supply strong credentials through a secure secret-management process.

### 3. Apply the Kubernetes manifests

```bash
kubectl apply -f k8s-specifications/
```

### 4. Verify the deployment

```bash
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get pvc
```

The local Kubernetes configuration exposes the applications through NodePorts:

- Vote: port `31000`
- Result: port `31001`

Actual access depends on the cluster and host networking configuration.

### 5. Remove the Kubernetes resources

```bash
kubectl delete -f k8s-specifications/
```

Check the impact on persistent data before deleting database resources.

## Container Security

The project includes several container-hardening measures.

### Non-root execution

The vote, result, and worker containers are configured to run as non-root users.

### Reduced privileges

The hardened application containers use:

- `allowPrivilegeEscalation: false`
- Dropped Linux capabilities.
- Explicit user and group IDs.
- Resource requests and limits.

### Health checks

Readiness and liveness probes are configured for the vote and result applications.

### Persistent storage

PostgreSQL uses a Kubernetes PersistentVolumeClaim to request persistent storage rather than relying exclusively on ephemeral container storage.

### Secret management

The result and database deployments reference a Kubernetes Secret named `db-credentials` rather than embedding database credentials directly in their manifests.

Kubernetes Secrets are not automatically equivalent to a complete production secrets-management solution. Additional controls, including appropriate RBAC and encryption at rest, may be required.

## CI/CD Pipeline

The primary capstone workflow is:

`.github/workflows/capstone-ci.yml`

### Pipeline stages

The workflow performs the following steps:

1. Checks out the repository.
2. Validates the Docker Compose configuration.
3. Builds the vote, result, and worker images.
4. Verifies selected Python packages in the vote image.
5. Scans the three application images with Trivy.
6. Authenticates to GitHub Container Registry on push events.
7. Tags the images with the Git commit SHA.
8. Pushes the images to GHCR.

### Vulnerability scanning

Trivy scans the application images for operating-system and library vulnerabilities. The configured workflow fails when it detects unfixed or fixed vulnerabilities classified as HIGH or CRITICAL, subject to the configured scanning options.

A successful GitHub Actions run was verified for the capstone workflow.

[View the GitHub Actions workflow runs](https://github.com/bayodeolamikunle/example-voting-app/actions)

### Published image names

The workflow publishes the application images using the following naming convention:

```text
ghcr.io/bayodeolamikunle/example-voting-app-vote:<commit-sha>
ghcr.io/bayodeolamikunle/example-voting-app-result:<commit-sha>
ghcr.io/bayodeolamikunle/example-voting-app-worker:<commit-sha>
```

Replace `<commit-sha>` with the full SHA of the intended commit.

Image visibility and access permissions should be checked before deployment to another Kubernetes cluster.

## Terraform Infrastructure

The `terraform/` directory contains the Terraform configuration for the Azure infrastructure.

### Infrastructure defined

The configuration defines:

- An Azure Virtual Network (VNet).
- An AKS subnet.
- An Azure Kubernetes Service cluster.
- A system-assigned managed identity.

The configuration references the existing Azure resource group:

`example-voting-capstone-rg`

The selected Azure region is `eastus`.

### AWS versus Azure

The original capstone brief refers to creating a Kubernetes cluster in the AWS default VPC.

This implementation uses Azure instead. Azure VNet networking is the corresponding Azure networking construct, but this is a provider substitution rather than an exact implementation of the AWS requirement. The substitution should be disclosed during assessment.

### Initialize Terraform

Ensure Azure CLI is authenticated and the intended subscription is selected:

```bash
az login
az account show
```

Initialize the Terraform working directory:

```bash
terraform -chdir=terraform init
```

### Format and validate

```bash
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
```

The configuration has passed Terraform formatting and validation checks.

### Review the proposed infrastructure

Before creating any Azure resources, inspect the plan:

```bash
terraform -chdir=terraform plan
```

Confirm that the selected subscription, permissions, resource configuration, and estimated costs are acceptable.

Only after reviewing and approving the plan should you provision the infrastructure:

```bash
terraform -chdir=terraform apply
```

Terraform validation alone does not prove that the infrastructure can be provisioned successfully.

### Destroy infrastructure

After the demonstration, review the destruction plan:

```bash
terraform -chdir=terraform plan -destroy
```

If you have confirmed that the resources can safely be removed, run:

```bash
terraform -chdir=terraform destroy
```

Do not destroy infrastructure that contains data or resources you need to retain.

**Cost consideration:** AKS and its associated compute and networking resources may incur charges. The AKS cluster has not yet been provisioned as part of the work verified for this project.

### Terraform file protection

The repository excludes local Terraform configuration and state files, including `terraform.tfvars` and Terraform state.

The provider lock file is committed to support reproducible provider selection.

## Helm Chart

The Helm chart is located at:

`helm/example-voting-app/`

The chart packages Kubernetes resources for:

- Vote.
- Result.
- Worker.
- PostgreSQL.
- Redis.
- Application services.
- PostgreSQL persistent storage.

The chart references the existing `db-credentials` Secret instead of embedding database passwords in its values.

### Validate the chart

Run:

```bash
helm lint helm/example-voting-app
```

Render the Kubernetes resources:

```bash
helm template example-voting-app helm/example-voting-app
```

The chart has passed Helm linting and rendered ten Kubernetes resources locally.

Successful rendering does not prove that the chart can be deployed successfully to AKS.

### Prepare for deployment

Before deploying the chart, verify all of the following:

- `kubectl` points to the intended cluster.
- The required `db-credentials` Secret exists in the target namespace.
- The image names and tags reference the intended GHCR images.
- The cluster can pull those images.
- The PostgreSQL persistent-volume configuration matches the cluster's available storage classes.
- The service exposure and network configuration are appropriate for the environment.

In particular, the current chart uses a PVC storage class named `standard`. Confirm that this storage class exists in the target cluster or update the chart to use an appropriate available storage class before deployment.

### Install or upgrade the Helm release

Once the prerequisites have been verified, the release can be installed or upgraded with:

```bash
helm upgrade --install example-voting-app ./helm/example-voting-app \
  --set vote.image=ghcr.io/bayodeolamikunle/example-voting-app-vote \
  --set result.image=ghcr.io/bayodeolamikunle/example-voting-app-result \
  --set worker.image=ghcr.io/bayodeolamikunle/example-voting-app-worker \
  --set-string vote.tag=<commit-sha> \
  --set-string result.tag=<commit-sha> \
  --set-string worker.tag=<commit-sha>
```

Replace `<commit-sha>` with the actual image tag. Ensure that the tag exists in GHCR before deploying.

### Verify the Helm release

```bash
helm status example-voting-app
helm history example-voting-app
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get pvc
```

### Roll back a release

If a release causes a problem, inspect the release history:

```bash
helm history example-voting-app
```

Choose the previous known-good revision and roll back:

```bash
helm rollback example-voting-app <revision>
```

Replace `<revision>` with the actual revision number from the release history.

Verify the resulting release and workload health:

```bash
helm status example-voting-app
helm history example-voting-app
kubectl get pods
```

These commands document the intended deployment and rollback procedure. A live Helm deployment and rollback must be performed and verified separately before they can be reported as completed.

## Testing and Validation

The following checks have been completed:

| Check | Result |
|---|---|
| Local Docker Compose application | Tested successfully |
| Kubernetes application | Tested locally |
| Application voting flow | Tested end to end |
| PostgreSQL persistent volume | Bound in the local cluster |
| Terraform formatting | Passed |
| Terraform validation | Passed |
| Helm lint | Passed |
| Helm template rendering | Passed; 10 resources rendered |
| GitHub Actions CI | Successful run verified |
| Trivy scans | All three scans passed in the verified workflow |
| GHCR publishing | Successful in the verified workflow |

### Outstanding verification

The following activities remain to be demonstrated:

- Successful Terraform provisioning of the Azure AKS infrastructure.
- Rebuilding and recreating the cloud environment from Terraform.
- Deploying the Helm chart to the target Kubernetes cluster.
- Demonstrating a successful Helm rollback after an intentionally bad release.
- Verifying that the deployed application uses the intended commit-SHA-tagged images.

## Repository Structure

```text
example-voting-app/
├── .github/
│   └── workflows/
│       ├── call-docker-build-result.yaml
│       ├── call-docker-build-vote.yaml
│       ├── call-docker-build-worker.yaml
│       └── capstone-ci.yml
├── helm/
│   └── example-voting-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           └── resources.yaml
├── terraform/
│   ├── main.tf
│   └── .terraform.lock.hcl
├── k8s-specifications/
├── vote/
├── result/
├── worker/
├── docker-compose.yml
├── docker-stack.yml
├── architecture.excalidraw.png
└── README.md
```

Local files such as `terraform.tfvars`, Terraform state, and downloaded provider data are excluded from the repository.

## Security Considerations

This project is intended for learning and demonstration, not as a production-ready deployment.

Before production use, additional work may be required in areas such as:

- Strong credential management and rotation.
- Kubernetes RBAC and namespace isolation.
- Encryption and protection of sensitive data.
- Container image provenance and supply-chain security.
- Network policies and restricted service exposure.
- Persistent storage configuration and backup recovery.
- Monitoring, logging, and incident response.
- Cloud identity, permissions, and cost management.
- Automated deployment and rollback verification.

Do not commit passwords, access tokens, private keys, or other sensitive credentials to Git.

## Project Status

This capstone demonstrates a hardened containerized application, Kubernetes manifests, Terraform configuration, a Helm chart, and an automated CI pipeline that builds, scans, tags, and publishes application images.

The local application, Terraform validation, Helm chart linting and rendering, and successful GitHub Actions run have been verified.

The Azure AKS deployment, complete infrastructure recreation, live Helm deployment, and live rollback remain outstanding verification activities. They should not be represented as completed until they have been performed successfully.

## Future Improvements

Potential improvements include:

- Automated deployment to AKS after successful CI checks.
- Automated Helm rollback testing.
- Infrastructure provisioning and teardown demonstrations.
- Automated Kubernetes manifest and Helm security scanning.
- Improved secret management.
- Centralized monitoring, logging, and alerting.
- Documented backup and disaster recovery procedures.
