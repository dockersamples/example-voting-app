# Data source for the default VPC in your region
data "aws_vpc" "default_vpc" {
  default = true
}

# Fetch default subnet for public
data "aws_subnets" "public_az_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }

  filter {
    name   = "availability-zone-id"
    values = ["use1-az1"]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnets" "public_az_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }

  filter {
    name   = "availability-zone-id"
    values = ["use1-az2"]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# private subnets
resource "aws_subnet" "private_az_a" {
  vpc_id                  = data.aws_vpc.default_vpc.id
  cidr_block              = local.private_az_a_subnet
  availability_zone_id    = "use1-az1"
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.cluster_name}-private-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_az_b" {
  vpc_id                  = data.aws_vpc.default_vpc.id
  cidr_block              = local.private_az_b_subnet
  availability_zone_id    = "use1-az2"
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.cluster_name}-private-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Elastic ip for NAT
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip"
  }
}

# Nat gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id

  # Existing default subnet in AZ 1
  subnet_id = one(data.aws_subnets.public_az_a.ids)

  tags = {
    Name = "${var.cluster_name}-nat"
  }
}

# Private route table
resource "aws_route_table" "private_rt" {
  vpc_id = data.aws_vpc.default_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt"
  }
}

# Associate private Subnet A/B with the Private Route Table
resource "aws_route_table_association" "private_rt_association_a" {
  subnet_id      = aws_subnet.private_az_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_association_b" {
  subnet_id      = aws_subnet.private_az_b.id
  route_table_id = aws_route_table.private_rt.id
}

# Security group for EKS Cluster control plane
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.aws_vpc.default_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-sg"
  }
}

# # EKS Cluster (Control Plane)
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids = [
      aws_subnet.private_az_a.id,
      aws_subnet.private_az_b.id
    ]
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

# # Managed Node Group (Worker Nodes)
resource "aws_eks_node_group" "worker" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node_role.arn

  subnet_ids = [
    aws_subnet.private_az_a.id,
    aws_subnet.private_az_b.id
  ]


  instance_types = [var.eks_instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}
