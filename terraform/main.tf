terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.1"
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

# this resource block creates a security group which only allows access on ports 22 
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

#|Note: "-1" specifies all protocals, so allows outbound traffic on all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# this resource block creates a security group which allows access on ports 22,80,443,8080, 9090 
resource "aws_security_group" "sg_managed" {
  name   = "sg_managed"
  vpc_id = aws_vpc.vpc.id

#|NOTE: "ingress" -> Inbound traffic rules, "egress" -> Outbound traffic rules)

#SSH access 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# PORT for cockpit
  ingress {
    from_port   = 9090
    to_port     = 9090
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

# HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
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
#|NOTE: it's better practice to use custom ami with eaverything sertup already rather then using "user-data" or provisioners to setup instance. thats why we use packer first
resource "aws_instance" "control_node" {
  # ami from packer build
  ami                         = var.ami_control
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_control.id]
  associate_public_ip_address = true

  # # copy ssh keys to managed node
  # provisioner "file" {
  #   source = "keys/"
  #   destination = "/home/ansible/.ssh"

  # connection {
  #   type = "ssh"
  #   user = "ansible"
  #   host = self.public_ip
  #   private_key = file("~/iac_project/keys/tf-packer")
  # }

  # }

  tags = {
    Name = "Control"
  }
}

# provisions 2 t2.small ec2 instances using ami image build earlier with packer
resource "aws_instance" "managed_node" {
  # Creates 2 identical ec2 instance 
  count = 2
  # ami from packer build
  ami                         = var.ami_managed
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_managed.id]
  associate_public_ip_address = true

  tags = {
    Name = "Managed_${count.index}"
  }
}

# this creates a file called "all_ips", stored in current working dir, that contains the public ip of "control" node and all the private ip's for the managed nodes
resource "local_file" "all_ips" {
filename = "public_ip"
content = <<EOF
%{for index, ip in aws_instance.managed_node.*.private_ip ~}
${aws_instance.control_node.public_ip} control
${ip} node_${index}
%{ endfor ~}
EOF
}
# this will print out the public ip of provision ec2 instance
output "control_node_public_ip" {
  value = aws_instance.control_node.public_ip
  description = "Public IP of control_node EC2 instance"
}

output "managed_node_private_ip" {
  value = aws_instance.managed_node.*.private_ip
  description = "Public IP's of all managed_node EC2 instances"
}


