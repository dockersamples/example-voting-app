# ---------- Deploy role created by the bootstrap stack ----------
data "aws_iam_role" "deploy" {
  name = var.deploy_role_name
}

# ---------- Cluster IAM role ----------
data "aws_iam_policy_document" "eks_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
}

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------- Node IAM role ----------
data "aws_iam_policy_document" "node_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", # lets nodes pull from ECR
  ])

  role       = aws_iam_role.node.name
  policy_arn = each.value
}

# ---------- EKS cluster ----------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_public_access  = true
    endpoint_private_access = false
    public_access_cidrs     = var.api_public_cidrs
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Avoid the much higher extended-support control plane charge
  upgrade_policy {
    support_type = "STANDARD"
  }

  # Cluster log types left off to avoid CloudWatch charges
  enabled_cluster_log_types = []

  depends_on = [aws_iam_role_policy_attachment.cluster]
}

# ---------- Managed node group ----------
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.public[*].id

  instance_types = var.node_instance_types
  capacity_type  = var.node_capacity_type
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired
    min_size     = var.node_min
    max_size     = var.node_max
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node,
    aws_route_table_association.public,
  ]
}

# ---------- Let the GitHub Actions deploy role use the cluster ----------
# Cluster admin keeps the demo simple. Hardening idea: pre-create the namespace and
# use a namespace-scoped AmazonEKSEditPolicy instead (document it in an ADR).
resource "aws_eks_access_entry" "gha_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_iam_role.deploy.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "gha_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_iam_role.deploy.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.gha_deploy]
}
