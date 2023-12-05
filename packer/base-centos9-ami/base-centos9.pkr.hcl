// {
//   "variables": {
//     "aws_access_key": "AKIA4CS25PKP5WVV4T42",
//     "aws_secret_key": "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"
//   },
//   "builders": [
//     {
//       "type": "amazon-ebs",
//       "access_key": "{{user `aws_access_key`}}",
//       "secret_key": "{{user `aws_secret_key`}}",
//       "region": "us-east-1",
//       "instance_type": "t2.medium",
//       "ami_name": "packer-base-ami-{{timestamp}}",
//       "source_ami_filter": {
//           "filters": {
//             "virtualization-type": "hvm",
//             "name": "CentOS Stream 9 x86_64 20231128",
//             "root-device-type": "ebs"
//           },
//           "owners": ["125523088429"],
//           "most_recent": true
//       },
//       "ssh_username": "ec2-user"
//     }
//   ]
// }

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "centos9" {
  ami_name      = "packer-centos9-ami-{{timestamp}}"
  instance_type = "t2.medium"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "CentOS Stream 9 x86_64 20231128"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["125523088429"]
  }
  ssh_username = "ec2-user"
}

build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.centos9"
  ]

provisioner "shell" {
  inline = [
    "echo update packages",
    // "sleep 30",
    "sudo dnf update -y",
    "sudo dnf install cloud-init -y"
  ]
}

provisioner "file" {
  source = "cloud-init/"
  destination = "/etc/cloud"
}

provisioner "shell" {
  scripts = [
    "scripts/setup.sh",
    "scripts/create_ansible_user.sh",
  ]
}

}