#!/bin/bash
echo updates
sudo dnf update -y
echo install epel package
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release epel-next-release -y
echo install ansible
sudo yum install ansible -y

# Add ansible user and setup sudo to allow no-password sudo for ansible 
sudo useradd -m -s /bin/bash ansible
sudo cp /etc/sudoers /etc/sudoers.orig
echo "ansible  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible

# Installing SSH key
sudo mkdir -p /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo cp /tmp/tf-packer.pub /home/ansible/.ssh/authorized_keys
sudo chmod 600 /home/ansible/.ssh/authorized_keys
sudo chown -R ansible /home/ansible/.ssh
sudo usermod --shell /bin/bash ansible
