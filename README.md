# Assets vs Liabilities Voting App

A distributed voting application customized to let users vote between **Assets** and **Liabilities**. This project demonstrates Docker, Kubernetes, AWS infrastructure, Terraform, Amazon ECR, and GitHub Actions CI/CD.

## Project Overview

The application consists of five components:

- **Vote:** Python web application that accepts votes.
- **Redis:** Temporarily stores incoming votes.
- **Worker:** Processes votes and writes them to the database.
- **Database:** PostgreSQL stores vote data.
- **Result:** Node.js web application displays the voting results.

## Architecture

```text
User's Browser
      |
      v
Vote Application (Python)
      |
      v
     Redis
      |
      v
Worker (.NET)
      |
      v
 PostgreSQL
      |
      v
Result Application (Node.js)
```

## Technologies Used

- Docker and Docker Compose
- Kubernetes and Amazon EKS
- Terraform
- Amazon ECR
- GitHub Actions and OIDC
- Python, Node.js, .NET, Redis, and PostgreSQL

## Repository Structure

- `.github/workflows/capstone-ci.yml` — CI and image publishing workflow.
- `k8s-specifications/` — Kubernetes deployment and service files.
- `terraform/main.tf` — AWS infrastructure configuration.
- `vote/` — Voting application.
- `result/` — Results application.
- `worker/` — Vote-processing worker.

## Run Locally

Requirements: Git, Docker, and Docker Compose.

Start the application from the project directory:

```bash
docker compose up --build
```

Open these pages:

- Voting: http://localhost:8080
- Results: http://localhost:8081

Stop the application with `Ctrl+C`. To stop and remove its Compose containers, run:

```bash
docker compose down
```

## AWS Infrastructure

The project uses AWS region `eu-west-1`.

- EKS cluster: `assets-liabilities-voting`
- EKS node group: `voting-workers`
- ECR repositories: `assets-liabilities-vote`, `assets-liabilities-result`, and `assets-liabilities-worker`
- Terraform configuration: `terraform/main.tf`

Review Terraform plans before applying changes to existing infrastructure.

## GitHub Actions and ECR

The workflow at `.github/workflows/capstone-ci.yml` builds and publishes application images to Amazon ECR.

GitHub Actions authenticates to AWS using OIDC. The IAM role is restricted to the configured repository and branch.

Image publishing and updating the running EKS deployments are separate operations in this project.

## Kubernetes Deployment

The Kubernetes manifests are in `k8s-specifications/`.

Configure access to the existing cluster:

```bash
aws eks update-kubeconfig --name assets-liabilities-voting --region eu-west-1 --profile capstone
```

Check the cluster and application:

```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get services
```

The current NodePort services use port `31000` for voting and `31001` for results. Access depends on the worker node's reachable address and AWS security rules.

## Testing

1. Confirm the five deployments are running: `vote`, `result`, `worker`, `redis`, and `db`.
2. Open the voting page.
3. Submit a vote for Assets or Liabilities.
4. Open the results page and confirm the vote is reflected.
5. Check the GitHub Actions workflow and verify that the application images exist in ECR.

## Security and Limitations

- Do not commit AWS credentials, tokens, or other secrets.
- Restrict network access to trusted IP addresses.
- Review Terraform plans before applying changes.
- Public IP addresses may change.
- The application is a learning demonstration, not a production-ready voting system.

## Project Outcome

This project demonstrates containerization, CI automation, image publishing, infrastructure as code, Kubernetes deployment, and end-to-end application testing on AWS.
