# ---------- Existing default VPC + IGW (looked up, never created or destroyed) ----------

data "aws_vpc" "default" {
  default = true
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_availability_zones" "selected" {
  filter {
    name   = "zone-id"
    values = var.az_ids
  }
}

locals {
  az_count = length(var.az_ids)
  az_names = data.aws_availability_zones.selected.names
  vpc_cidr = data.aws_vpc.default.cidr_block

  # /20 blocks after the six AWS default subnets (indexes 0-5)
  public_cidrs  = [for i in range(local.az_count) : cidrsubnet(local.vpc_cidr, 4, 6 + i)] # 172.31.96.0/20, 172.31.112.0/20
  private_cidrs = [for i in range(local.az_count) : cidrsubnet(local.vpc_cidr, 4, 8 + i)] # 172.31.128.0/20, 172.31.144.0/20

  public_nacl_ingress = [
    { rule_no = 100, protocol = "tcp", cidr = "0.0.0.0/0", from = 80, to = 80 },      # HTTP
    { rule_no = 110, protocol = "tcp", cidr = "0.0.0.0/0", from = 443, to = 443 },    # HTTPS
    { rule_no = 120, protocol = "tcp", cidr = "0.0.0.0/0", from = 1024, to = 65535 }, # return traffic
    { rule_no = 130, protocol = "udp", cidr = "0.0.0.0/0", from = 1024, to = 65535 }, # return traffic
    { rule_no = 140, protocol = "-1", cidr = local.vpc_cidr, from = 0, to = 0 },      # from inside VPC
  ]

  private_nacl_ingress = [
    { rule_no = 100, protocol = "-1", cidr = local.vpc_cidr, from = 0, to = 0 },      # from inside VPC
    { rule_no = 110, protocol = "tcp", cidr = "0.0.0.0/0", from = 1024, to = 65535 }, # replies via NAT only
    { rule_no = 120, protocol = "udp", cidr = "0.0.0.0/0", from = 1024, to = 65535 }, # replies via NAT only
  ]
}

# ---------- Subnets ----------

resource "aws_subnet" "public" {
  count                   = local.az_count
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.cluster_name}-public-${local.az_names[count.index]}"
    Tier                                        = "public"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private" {
  count                   = local.az_count
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = local.private_cidrs[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "${var.cluster_name}-private-${local.az_names[count.index]}"
    Tier                                        = "private"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ---------- NAT gateway (single, in first public subnet) ----------

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.cluster_name}-nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.cluster_name}-nat" }
}

# ---------- Route tables ----------

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.default.id
  tags   = { Name = "${var.cluster_name}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.default.id
  tags   = { Name = "${var.cluster_name}-private-rt" }
}

# Private subnets: outbound via NAT only, no route from the internet gateway
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ---------- Network ACLs: one per subnet ----------

resource "aws_network_acl" "public" {
  count      = local.az_count
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = [aws_subnet.public[count.index].id]

  dynamic "ingress" {
    for_each = local.public_nacl_ingress
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = "allow"
      cidr_block = ingress.value.cidr
      from_port  = ingress.value.from
      to_port    = ingress.value.to
    }
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "${var.cluster_name}-public-nacl-${local.az_names[count.index]}" }
}

resource "aws_network_acl" "private" {
  count      = local.az_count
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = [aws_subnet.private[count.index].id]

  dynamic "ingress" {
    for_each = local.private_nacl_ingress
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = "allow"
      cidr_block = ingress.value.cidr
      from_port  = ingress.value.from
      to_port    = ingress.value.to
    }
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "${var.cluster_name}-private-nacl-${local.az_names[count.index]}" }
}