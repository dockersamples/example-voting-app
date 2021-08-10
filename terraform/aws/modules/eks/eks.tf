variable "EnvType" {}
variable "EnvName" {}
variable "EnvRegion" {}
variable "subnets" {
      type    = list
  default = [" "]
}
variable "vpc_id"{}
variable "eks_cluster_name" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  cluster_name    = "${var.eks_cluster_name}"
  cluster_version = "1.20"
  subnets         = "${var.subnets}"
  vpc_id = "${var.vpc_id}"

  node_groups = {
    eks_nodes = {
      desired_capacity = 1
      max_capacity     = 3
      min_capaicty     = 1

      instance_type = "m4.large"
    }
  }
}