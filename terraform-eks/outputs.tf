output "vpc_id" {
  value = data.aws_vpc.default_vpc.id
}

output "vpc_cidr_block" {
  value = data.aws_vpc.default_vpc.cidr_block
}

output "public_subnet_id_az_a" {
  value = data.aws_subnets.public_az_a.ids
}

output "public_subnet_id_az_b" {
  value = data.aws_subnets.public_az_b.ids
}

output "private_subnet_id_az_a" {
  value = {
    id         = aws_subnet.private_az_a.id
    cidr_block = aws_subnet.private_az_a.cidr_block
  }
}

output "private_subnet_id_az_b" {
  value = {
    id         = aws_subnet.private_az_b.id
    cidr_block = aws_subnet.private_az_b.cidr_block
  }
}

output "eks_sg" {
  value = aws_security_group.eks_cluster.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}
