terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
  }
  required_version = ">= 0.14.5"
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

# this resource block creates a security group which allows access on ports 22,80, and 8080 
resource "aws_security_group" "sg_control" {
  name   = "sg_control"
  vpc_id = aws_vpc.vpc.id

#|NOTE: "ingress" -> Inbound traffic rules, "egress" -> Outbound traffic rules)

#SSH access 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#|Note: "-1" specifies all protocals, so allows outbound traffic on all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#|NOTE: since were using ami's created with packer, the ami image will be what prints to screen after "packer build" command is successful, you can also find it in aws dashboard under [ Images > AMIs > Owned by me ]
resource "aws_instance" "control_node" {
  # ami from packer build
  ami                         = var.ami_control
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_control.id]
  associate_public_ip_address = true

  tags = {
    Name = "Learn-Packer"
  }
}

# this will print out the public ip of provision ec2 instance
output "public_ip" {
  description = "Public IP of control_node EC2 instance"
  value = aws_instance.control_node.public_ip
}
