variable "ami" {
  default = "ami-023c11a32b0207432"
}

# instance_type for managed servers
variable "instance_managed" {
  default = "t2.micro"
}

# instance_type for control server
variable "instance_control" {
  default = "t2.medium"
}