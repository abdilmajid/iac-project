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
  # this will create an ami image in our "owned ami" 
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
    # this is centos.org owner
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
    "echo installing cloud-init",
    "sudo dnf install cloud-init -y"
  ]
}

# we will use cloud-init to create the ansible user with default pass
# default pass is "changeme" 
provisioner "file" {
  source = "files/defaults.cfg"
  destination = "/tmp/defaults.cfg"
}

# moving default.cfs from /tmp to proper directory
provisioner "shell" {
  inline = [ 
    "echo moving defaults.cfg file",
    "sudo mv /tmp/defaults.cfg /etc/cloud/cloud.cfg.d/defaults.cfg" 
    ]
}
# the shell script will install ansible from repo,
provisioner "shell" {
  scripts = [
    "scripts/setup.sh",
    "scripts/ansible_sudo.sh"
  ]
}

}