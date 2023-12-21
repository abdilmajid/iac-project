#!/bin/bash

# grabs hostname
CONTROL=$(grep control ../terraform/private_ip | cut -f2 -d' ')
NODE_0=$(grep node0 ../terraform/private_ip | cut -f2 -d' ')
NODE_1=$(grep node1 ../terraform/private_ip | cut -f2 -d' ')

# grabs the public ip address and assigns to variable
PUB_CONTROL=$(grep control ../terraform/public_ip | cut -f1 -d' ')
PUB_NODE_0=$(grep node0 ../terraform/public_ip | cut -f1 -d' ')
PUB_NODE_1=$(grep node1 ../terraform/public_ip | cut -f1 -d' ')

# grabs the private ip address and assigns to variable
PRV_CONTROL=$(grep control ../terraform/private_ip | cut -f1 -d' ')
PRV_NODE_0=$(grep node0 ../terraform/private_ip | cut -f1 -d' ')
PRV_NODE_1=$(grep node1 ../terraform/private_ip | cut -f1 -d' ')


# Here we copy the 
for i in $PUB_CONTROL $PUB_NODE_0 $PUB_NODE_1; 
do 
  ssh-keyscan -H ${i} >> ~/.ssh/known_hosts
done;

# First check if already appened contents to /etc/hosts
CHK_HOSTS=$(ssh -i ../keys/tf-packer ansible@$PUB_CONTROL "grep control /etc/hosts" 2>/dev/null)
CHK_HOSTS=$(echo $?)

CHK
# here we will assume that if "control" private ip already exists in hosts file, then contents have been appended 
if [ $CHK_HOSTS -eq 0 ]; then
  echo "hosts file already appened"
else
  # Here we update(append) the /etc/hosts file for all provisioned instances to include the private ip's of all instances
  for i in $PUB_CONTROL $PUB_NODE_0 $PUB_NODE_1; do \
  # here we add the public-ip's to know_hosts file
  # ssh-keyscan -H ${i} >> ~/.ssh/known_hosts
  scp -i ../keys/tf-packer ../terraform/private_ip ansible@${i}:/tmp;
  # check if ip's already appended to hosts file
  ssh -i ../keys/tf-packer ansible@${i} "cat /tmp/private_ip | sudo tee -a /etc/hosts"; done
fi


# Creates playbook directory if it does not exist, then copies all plays to this directory, we only copy files to control node
if ssh -i ../keys/tf-packer ansible@$PUB_CONTROL "test ! -d ~/playbook";
then
  ssh -i ../keys/tf-packer ansible@$PUB_CONTROL "mkdir ~/playbook";
  # Copy all plays in "playbooks" to "~/playbooks" in control node
  scp -i ../keys/tf-packer playbook/ -r ansible@${PUB_CONTROL}:~/playbook
else
  echo "~/playbook already exists"
fi

# # Copy ansible.cfg(config) and inventory file to ansible users home directory
# # for i in files/ansible.cfg files/inventory files/.vimrc ; 
# for i in files/ 
# do 
#   scp -i ../keys/tf-packer ${i} -r ansible@${PUB_CONTROL}:~;
# done
# 1st check if files already copied to control node
if ssh i ../keys/tf-packer ansible@$PUB_CONTROL "test ! -e ~/inventory";
then 
  for i in files/{.vimrc,ansible.cfg,inventory}; do \
    scp -i ../keys/tf-packer ${i} ansible@${PUB_CONTROL}:~;
  done;
else
  echo "files already copied"
fi;







## Script to check acounts created and files transfered
sh check.sh

# Script to update hostnames for each instance
sh update_hostnames.sh
