/*
|Note: Credential stored in env variables
- so we don't need to include the aws provider block/file because terraform will grab it from env
% export AWS_ACCESS_KEY_ID="anaccesskey"
% export AWS_SECRET_ACCESS_KEY="asecretkey"
% export AWS_REGION="us-east-1"
- we can also store credentials inside files
Ex: 
"~/.aws/credentials"
[default]
aws_access_key_id="accesskey"
aws_secret_access_key="secretkey"
"~/.aws/config"
[default]
region=us-east-1
*/

# Creates IAM(Identity & Access Management) User
# this allows us to access resources for the provisioned instance
resource "aws_iam_user" "admin-user" {
  name = "abdil"
  tags = {
    Description = "Technical Team Leader"
  }
}

# need to attach a policy for IAM user, this is admin user so we give them admin access
resource "aws_iam_policy" "adminUser" {
  name = "AdminUser"
  # we can insert policy with Heredoc Syntax or just pass into file() function 
  policy = file("admin-policy.json")
}

# This block will link iam policy to the given user
resource "aws_iam_user_policy_attachment" "abdil-admin-access" {
  user = aws_iam_user.admin-user.name
  policy_arn = aws_iam_policy.adminUser.arn
}

# This provisions the control node 
resource "aws_instance" "control" {
  ami  = var.ami_centos8 # RHEL9 
  instance_type = var.instance_control
  # if no default subnet, then we can use setup_id
  # make sure to use correct subnet
  subnet_id = "subnet-04e71508f10ab9c7b"

  # below will update the repo, then install epel repo which contains our ansible package, then we install the anisible package
  
  # user_data = <<EOF
  # #!/bin/bash
  # sudo dnf update -y
  # sudo dnf install \
  # https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
  # sudo dnf install ansible -y
  # EOF
  # user_data = <<EOF
  # #!/bin/bash
  # sudo adduser --disabled-password --gecos '' abdil
  # sudo mkdir -p /home/abdil/.ssh
  # sudo touch /home/abdil/.ssh/authorized_keys
  # sudo echo '${var.MY_USER_PUBLIC_KEY}' > authorized_keys
  # sudo mv authorized_keys /home/abdil/.ssh
  # sudo chmod 700 /home/abdil/.ssh
  # sudo chmod 600 /home/abdil/.ssh/authorized_keys
  # sudo usermod -aG sudo abdil
  # EOF

  tags = {
    Name = "control"
    Description = "Ansible Control Node"
  }


# This will create create the ansible user, and allow us to use sudo without entering a password, 
#|Note: we can't use scripts with "remote-exec"
  provisioner "remote-exec" {
    inline = [ 
      "sudo adduser --disabled-password --gecos '' ansible",
      "sudo echo 'ansible ALL=(ALL:ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ansible",
      "sudo mkdir -p /home/ansible/.ssh",
      "sudo touch /home/ansible/.ssh/authorized_keys",
      "sudo echo '${var.MY_USER_PUBLIC_KEY}' > authorized_keys",
      "sudo mv authorized_keys /home/ansible/.ssh",
      "sudo chown -R ansible:ansible /home/ansible/.ssh",
      "sudo chmod 700 /home/ansible/.ssh",
      "sudo chmod 600 /home/ansible/.ssh/authorized_keys",
      "sudo usermod -aG sudo ansible"
     ]
  }

# this connects to our instance as ubuntu user inorder to execute our commands using "remote-exec"
  connection {
    type = "ssh"
    host = self.public_ip
    user = "cloud_user"
    private_key = file("/home/abdil/.ssh/id_rsa")
  }
  
  #can use key_name argument to connect ssh keys to aws_instance
  # or "aws_key_pair.control.id"
  key_name = "control_node" 
  # below we use vpc_security_group_ids argument to connect aws_security_group to aws_instance
  vpc_security_group_ids = [ aws_security_group.ssh-access.id ]
}

#Inorder to ssh into our instance we need to use "aws_key_pair", 
#1st: create the key pair  
#2nd: user "aws_key_pair" resource to connect to aws_instance
resource "aws_key_pair" "control" {
  key_name = "control_node"
  public_key = file("/home/abdil/.ssh/id_rsa.pub")
}

# # This block provisions managed node1
# resource "aws_instance" "node1" {
#   ami = var.ami
#   instance_type = var.instance_managed

#   tags = {
#     Name = "node1"
#     Description = "Ansbile Managed Node"
#   }
# }

# # This block provisions managed node2
# resource "aws_instance" "node1" {
#   ami = var.ami
#   instance_type = var.instance_managed

#   tags = {
#     Name = "node2"
#     Description = "Ansbile Managed Node2"
#   }
# }
#

# we need to setup networking so we can ssh into the instance, so we need to use "aws_security_group"
resource "aws_security_group" "ssh-access" {
  name = "ssh-access"
  description = "Allow SSH access from the internet"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# the "output" block will print out the oublic ip of our instance
# we could search through the terraform.tfstate file or execute "terraform show" command to get this info too
output "public_ip" {
  description = "Public IP of Control EC2 instance"
  value = aws_instance.control.public_ip
} 

