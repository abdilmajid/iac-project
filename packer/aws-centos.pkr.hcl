packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "centos8" {
  # name of ami were going to create
  ami_name      = "centos-packer-image"
  instance_type = "t2.micro"
  region        = "us-east-1"
  # this is the name of the image we want to use
  source_ami = "ami-008b6354fbeed6440"
  # name of user when logging into instance
  ssh_username = "root"
  #|Note: credentials stored in shared credentials file "~/.aws"

}

variable "MY_USER_PUBLIC_KEY" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCH7MerSH8mZO2OA3DqfRbec+CtbDOQz+PchgMCUvSdyPMKK074t+L8zKywRaLn+5uSJ5CtgEcX6glLjJRIw2Ia7uJPoDJZkU/K+7iru6IG33dXCtRceqmdYeF2zxG10r3stTFYF9RUlFqKYWSEDfUgQuigFsCffFp6uLcn/UL8AyPeLkPCxGPrY/Oe/45c1V0r/dUjk5KO8kLdU655UP5Ia1x3OQkTeCGlzLsSbVei3hV7tqfcN6zC+vUTxZPNBoylUZKhoTfL1z7PoEQ6C0fh1AseGeUdKNP1XmNKI/dsLvE6XaQNGQKHZI9/qV2bNdIXkLmwV8UQTXtCEUCoucaHYyUTFspKpkMyWt0aR5i5pPVeKr3/KnYeJqivTRN0Ld02nMtsBS9/ijvrVat+bPSWIMXvqjyktWKlwHfGQzGGSzKDJ2R3eotUhpvJhiIX3dxMdoliNcOwB65/7fpOmtZKRYsFu1q9/jLhSzJLxQwXPuTOG1YepekE9Lsw8xjmLXk= abdil@control"
}


build {
  name   = "centos-build"
  sources = ["amazon-ebs.centos8"]
  # we use the shell provisioner to execute our commands to modify our image
  # below we will create the ansible user
  provisioner "shell" {
    inline = [
      "adduser --disabled-password --gecos '' ansible",
      "echo 'ansible ALL=(ALL:ALL) NOPASSWD:ALL' | tee /etc/sudoers.d/ansible",
      "mkdir -p /home/ansible/.ssh",
      "touch /home/ansible/.ssh/authorized_keys",
      "echo '${var.MY_USER_PUBLIC_KEY}' > authorized_keys",
      "mv authorized_keys /home/ansible/.ssh",
      "chown -R ansible:ansible /home/ansible/.ssh",
      "chmod 700 /home/ansible/.ssh",
      "chmod 600 /home/ansible/.ssh/authorized_keys",
      "usermod -aG sudo ansible"
    ]
  }

  post-processor "vagrant" {}
  post-processor "compress" {}

}