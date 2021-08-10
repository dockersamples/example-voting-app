variable "EnvType" {}
variable "EnvName" {}
variable "EnvRegion" {}
variable "vpcCIDRblock"{}
variable "destinationCIDRblock" {}
variable "PRIVATE_CIDR_Blocks" {
  type    = list
  default = [" "]
}
variable "PUBLIC_CIDR_Blocks" {
  type    = list
  default = [" "]
}
variable "eipnames" {
    type    = list
  default = [" "]
}
variable "private_ingress_ports" {
      type    = list
  default = [" "]
}
variable "eks_cluster_name" {}

resource "aws_vpc" "main" {
  cidr_block       = "${var.vpcCIDRblock}"
  instance_tenancy = "default"
  enable_dns_hostnames=true
  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

data "aws_availability_zones" "all" {}

output "az" {
  value = "${data.aws_availability_zones.all.names}"
}

resource "aws_subnet" "private_subnet" {
  count             = "${length(data.aws_availability_zones.all.names)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.PRIVATE_CIDR_Blocks, count.index)}"
  availability_zone = "${data.aws_availability_zones.all.names[count.index]}"

  tags = {
    Name = "Private_Subnet_${var.EnvName}_${var.EnvType}_${data.aws_availability_zones.all.names[count.index]}"
    EnvType = "${var.EnvType}"
    EnvName = "${var.EnvName}"
    Creator   = "This private subnet is generated over Terraform"
    Tier="Private"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

output "all_private_sub_out" {
 value = "${aws_subnet.private_subnet.*.id}"
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table_association" "private_rtb_association" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_subnet" "public_subnet" {
  count             = "${length(data.aws_availability_zones.all.names)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.PUBLIC_CIDR_Blocks, count.index)}"
  availability_zone = "${data.aws_availability_zones.all.names[count.index]}"
  map_public_ip_on_launch="true"

  tags = {
    Name = "Public_Subnet_${var.EnvName}_${var.EnvType}_${data.aws_availability_zones.all.names[count.index]}"
    EnvType = "${var.EnvType}"
    EnvName = "${var.EnvName}"
    Creator   = "This public subnet is generated over Terraform"
    Tier="Public"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main.id}"
}
resource "aws_internet_gateway" "VPC_GW" {
  vpc_id = "${aws_vpc.main.id}"
}
resource "aws_eip" "source_ip" {
  count= "1"
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.source_ip.0.id}"
  subnet_id     = "${aws_subnet.public_subnet.0.id}"
  depends_on    = ["aws_internet_gateway.VPC_GW"]
}

resource "aws_route" "VPC_NAT_access" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "${var.destinationCIDRblock}"
  nat_gateway_id              ="${aws_nat_gateway.gw.id}"
}

resource "aws_route" "VPC_internet_access" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "${var.destinationCIDRblock}"
  gateway_id             = "${aws_internet_gateway.VPC_GW.id}"
}

resource "aws_route_table_association" "public_rtb_association" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}
