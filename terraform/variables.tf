variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.1.0.0/24"
}

variable "environment_tag" {
  description = "Environment tag"
  default     = "Learn"
}

variable "region"{
  description = "The region Terraform deploys your instance"
  default = "us-east-1"
}

# ami for control node, build using packer
variable "ami_control" {
  default = "ami-03fb2d9ea9812a79d"
  description = "ami for ansible control node"
}

# ami for managed nodes, built using packer
variable "ami_managed" {
  default = "ami-0399510b3b7364c1d"
  description = "ami for ansible managed node"
}