
locals {
  private_az_a_subnet = cidrsubnet(data.aws_vpc.default_vpc.cidr_block, 4, 6)
  private_az_b_subnet = cidrsubnet(data.aws_vpc.default_vpc.cidr_block, 4, 7)
}
