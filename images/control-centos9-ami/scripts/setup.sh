#!/bin/bash
echo updates
sudo dnf update -y
echo install epel and tab-completion packages
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release epel-next-release bash-completion mlocate vim -y
# this installs ansible package
echo install ansible
sudo dnf install ansible -y
# we use locate command to find bash_completion.sh on system, first we need to populate/update db for mlocate
sudo updatedb
sudo sh $(locate bash_completion.sh)

# Add ansible user and setup sudo to allow no-password sudo for ansible 
sudo useradd -m -s /bin/bash ansible
sudo cp /etc/sudoers /etc/sudoers.orig
echo "ansible  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
# This updates client ssh config so that ansible credentials automatically used, so only need to "ssh <hostname>"
echo "User ansible" | sudo tee /etc/ssh/ssh_config.d/ansible.conf
echo "IdentityFile ~/.ssh/tf-packer" | sudo tee /etc/ssh/ssh_config.d/ansible.conf

# Installing SSH key
#|NOTE: make sure you generate a new ssh key on working dir name "tf-packer"
sudo mkdir -p /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo cp /tmp/tf-packer.pub /home/ansible/.ssh/authorized_keys
# sudo touch /home/ansible/.ssh/tf-packer.pub
sudo touch /home/ansible/.ssh/tf-packer
# sudo cp /tmp/tf-packer.pub /home/ansible/.ssh/tf-packer.pub
sudo cp /tmp/tf-packer /home/ansible/.ssh/tf-packer
sudo chmod 600 /home/ansible/.ssh/authorized_keys
# sudo chmod 644 /home/ansible/.ssh/tf-packer.pub
sudo chmod 600 /home/ansible/.ssh/tf-packer
sudo chown -R ansible:ansible /home/ansible/.ssh
sudo usermod --shell /bin/bash ansible
