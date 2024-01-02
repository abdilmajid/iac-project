packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "managed_centos9" {
  # this will create an ami image in our "owned ami" 
  ami_name      = "pk-managed-{{timestamp}}"
  instance_type = "t2.medium"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "CentOS Stream 9 x86_64 20231128"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    # this is centos.org owner
    owners      = ["125523088429"]
  }
  ssh_username = "ec2-user"
}

build {
  name    = "managed"
  sources = [
    "source.amazon-ebs.managed_centos9"
  ]

  provisioner "file" {
    source = "../../keys/tf-packer.pub"
    destination = "/tmp/tf-packer.pub"
  }

  provisioner "shell" {
    script = "scripts/setup.sh"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }


  post-processor "shell-local" {
    script = "ami-man-update.sh"
  }

}