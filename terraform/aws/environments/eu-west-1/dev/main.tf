provider "aws" {
  region                  = "${var.EnvRegion}"
  shared_credentials_file = "%USERPROFILE%/.aws/credentials"
  profile                 = "terraform"
}

terraform {
  backend "s3" {
    bucket = "jntnbrmn-terraform-state"
    key    = "EU-West-1/dev/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  eks_cluster_name = "eks_${var.EnvName}_${var.EnvType}"
}


module "vpc" {
  source                       = "../../../modules/vpc"
  EnvType                      = "${var.EnvType}"
  EnvRegion                    = "${var.EnvRegion}"
  EnvName                      = "${var.EnvName}"
  vpcCIDRblock                 = "${var.vpcCIDRblock}"
  destinationCIDRblock         = "${var.destinationCIDRblock}"
  private_ingress_ports        = ["${var.private_ingress_ports}"]
  PRIVATE_CIDR_Blocks          = "${var.PRIVATE_CIDR_Blocks}"
  PUBLIC_CIDR_Blocks          = "${var.PUBLIC_CIDR_Blocks}"
  eks_cluster_name             = "${local.eks_cluster_name}"
}

module "eks" {
  source                       = "../../../modules/eks"
  EnvType                      = "${var.EnvType}"
  EnvRegion                    = "${var.EnvRegion}"
  EnvName                      = "${var.EnvName}"
  vpc_id                       = "${module.vpc.vpc_id}"
  subnets                      = "${module.vpc.all_private_sub_out}"
  eks_cluster_name             = "${local.eks_cluster_name}"
}

