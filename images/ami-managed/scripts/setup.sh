#!/bin/bash
echo updates
sudo dnf update -y
echo install epel and tab-completion packages
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release epel-next-release bash-completion mlocate -y
# we use locate command to find bash_completion.sh on system, first we need to populate/update db for mlocate
sudo updatedb
sudo sh $(locate bash_completion.sh)


# Add ansible user and setup sudo to allow no-password sudo for ansible 
sudo useradd -m -s /bin/bash ansible
sudo cp /etc/sudoers /etc/sudoers.orig
echo "ansible  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible

# Installing SSH key
#|NOTE: make sure you generate a new ssh key on working dir name "tf-packer"
sudo mkdir -p /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo cp /tmp/tf-packer.pub /home/ansible/.ssh/authorized_keys
sudo chmod 600 /home/ansible/.ssh/authorized_keys
# gives ansible user pass of "changeme", this is so we can setup connection between control and managed nodes
#Need to create new ssh keys inside "control node"
#|NOTE: need to make sure password is changed 
# sudo echo "changeme" | sudo passwd --stdin ansible
sudo chown -R ansible:ansible /home/ansible/.ssh
sudo usermod --shell /bin/bash ansible

