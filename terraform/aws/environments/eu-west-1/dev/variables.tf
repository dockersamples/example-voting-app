# variables.tf
variable "EnvType" {
  default = "test"
}

variable "EnvName" {
  default = "toluna"
}

variable "EnvRegion" {
  default = "eu-west-1"
}

variable "vpcCIDRblock" {
  default = "10.20.0.0/16"
}

variable "destinationCIDRblock" {
  default = "0.0.0.0/0"
}

variable "PRIVATE_CIDR_Blocks"{
  type = list
  default = ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"]
}
variable "PUBLIC_CIDR_Blocks"{
  type = list
  default = ["10.20.48.0/20", "10.20.64.0/20", "10.20.80.0/20"]
}

variable "ingressCIDRblock" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "private_ingress_ports" {
  type    = list
  default = ["22","443"]
}



