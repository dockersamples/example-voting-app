
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "voting_app_artifacts" {
  bucket_prefix = "${var.project_name}-${var.environment}-artifacts-"

  force_destroy = false

  tags = {
    Name        = "${var.project_name}-artifacts"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "voting_app_artifacts" {
  bucket = aws_s3_bucket.voting_app_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "voting_app_artifacts" {
  bucket = aws_s3_bucket.voting_app_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "voting_app_artifacts" {
  bucket = aws_s3_bucket.voting_app_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Identify existing public subnets for the Voting App EKS cluster.
resource "aws_ec2_tag" "eks_cluster_subnet_a" {
  resource_id = "subnet-073da4d7e92dc34ad"
  key         = "kubernetes.io/cluster/${var.project_name}-${var.environment}"
  value       = "shared"
}

resource "aws_ec2_tag" "eks_cluster_subnet_b" {
  resource_id = "subnet-0961a5f5b1f0a3750"
  key         = "kubernetes.io/cluster/${var.project_name}-${var.environment}"
  value       = "shared"
}

resource "aws_ec2_tag" "eks_cluster_subnet_c" {
  resource_id = "subnet-0a8d7c8667f511e5d"
  key         = "kubernetes.io/cluster/${var.project_name}-${var.environment}"
  value       = "shared"
}

# Mark the subnets as public for AWS load-balancer discovery.
resource "aws_ec2_tag" "public_subnet_elb_a" {
  resource_id = "subnet-073da4d7e92dc34ad"
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_elb_b" {
  resource_id = "subnet-0961a5f5b1f0a3750"
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_elb_c" {
  resource_id = "subnet-0a8d7c8667f511e5d"
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

# IAM role assumed by the EKS control plane.
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM role assumed by EC2 worker nodes.
resource "aws_iam_role" "eks_node" {
  name = "${var.project_name}-${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS control plane.
resource "aws_eks_cluster" "voting_app" {
  name     = "${var.project_name}-${var.environment}"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = [
      "subnet-073da4d7e92dc34ad",
      "subnet-0961a5f5b1f0a3750",
      "subnet-0a8d7c8667f511e5d"
    ]

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# Small managed worker-node group for learning.
resource "aws_eks_node_group" "voting_app" {
  cluster_name    = aws_eks_cluster.voting_app.name
  node_group_name = "${var.project_name}-${var.environment}-workers"
  node_role_arn   = aws_iam_role.eks_node.arn

  subnet_ids = [
    "subnet-073da4d7e92dc34ad",
    "subnet-0961a5f5b1f0a3750",
    "subnet-0a8d7c8667f511e5d"
  ]

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker,
    aws_iam_role_policy_attachment.eks_node_cni,
    aws_iam_role_policy_attachment.eks_node_ecr
  ]
}
