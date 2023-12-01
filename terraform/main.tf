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

# This provisions the control node 
resource "aws_instance" "control" {
  ami  = var.ami # RHEL9 
  instance_type = var.instance_control
  # if no default subnet, then we can use setup_id
  # make sure to use correct subnet
  subnet_id = "subnet-037d9537bf26aa812"

  # below will update the repo, then install epel repo which contains our ansible package, then we install the anisible package
  user_data = <<EOF
              sudo dnf update -y
              sudo dnf install \
              https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
              sudo dnf install ansible -y
              EOF

  tags = {
    Name = "control"
    Description = "Ansible Control Node"
  }
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