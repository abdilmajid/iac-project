# variable "ami_aws" {
#   default = "ami-0230bd60aa48260c6"
# }

# variable "ami_ubuntu" {
#   default = "ami-0fc5d935ebf8bc3bc"
# }

# variable "ami_centos8" {
#   default = "ami-008b6354fbeed6440"
# }
# # instance_type for managed servers
# variable "instance_managed" {
#   default = "t2.micro"
# }

# # instance_type for control server
# variable "instance_control" {
#   default = "t2.medium"
# }

# # SSH Public key
# variable "MY_USER_PUBLIC_KEY" {
#   default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCH7MerSH8mZO2OA3DqfRbec+CtbDOQz+PchgMCUvSdyPMKK074t+L8zKywRaLn+5uSJ5CtgEcX6glLjJRIw2Ia7uJPoDJZkU/K+7iru6IG33dXCtRceqmdYeF2zxG10r3stTFYF9RUlFqKYWSEDfUgQuigFsCffFp6uLcn/UL8AyPeLkPCxGPrY/Oe/45c1V0r/dUjk5KO8kLdU655UP5Ia1x3OQkTeCGlzLsSbVei3hV7tqfcN6zC+vUTxZPNBoylUZKhoTfL1z7PoEQ6C0fh1AseGeUdKNP1XmNKI/dsLvE6XaQNGQKHZI9/qV2bNdIXkLmwV8UQTXtCEUCoucaHYyUTFspKpkMyWt0aR5i5pPVeKr3/KnYeJqivTRN0Ld02nMtsBS9/ijvrVat+bPSWIMXvqjyktWKlwHfGQzGGSzKDJ2R3eotUhpvJhiIX3dxMdoliNcOwB65/7fpOmtZKRYsFu1q9/jLhSzJLxQwXPuTOG1YepekE9Lsw8xjmLXk= abdil@control"
# }

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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
}

