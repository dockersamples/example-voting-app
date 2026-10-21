terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "voting-app-tfstate-038884640469"
    key          = "bootstrap/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      Project   = "voting-app-capstone"
      ManagedBy = "terraform"
      Stack     = "bootstrap"
    }
  }
}

variable "cluster_name" {
  type    = string
  default = "voting-app"
}

data "aws_caller_identity" "current" {}

# Intended design was GitHub OIDC (no long-lived keys). This account's SCP
# denies all iam:*OpenIDConnectProvider* actions, so CI uses a dedicated,
# minimally scoped IAM user whose keys live only in GitHub Actions secrets.
resource "aws_iam_user" "github_deploy" {
  name = "${var.cluster_name}-github-deploy"
}

# AWS-side permission: only enough to find the cluster and build a kubeconfig.
# What it may do INSIDE Kubernetes is granted by the EKS access entry (terraform/access.tf).
data "aws_iam_policy_document" "github_deploy" {
  statement {
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:aws:eks:eu-north-1:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"]
  }
}

resource "aws_iam_user_policy" "github_deploy" {
  name   = "eks-describe"
  user   = aws_iam_user.github_deploy.name
  policy = data.aws_iam_policy_document.github_deploy.json
}

output "github_deploy_user_arn" {
  value = aws_iam_user.github_deploy.arn
}
