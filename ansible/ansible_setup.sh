#!/bin/bash

# grabs the public ip address and assigns to variable
PUB_CONTROL=$(grep control ../terraform/public_ip | cut -f1 -d' ')
PUB_NODE_0=$(grep node0 ../terraform/public_ip | cut -f1 -d' ')
PUB_NODE_1=$(grep node1 ../terraform/public_ip | cut -f1 -d' ')

# grabs the private ip address and assigns to variable
PRV_CONTROL=$(grep control ../terraform/private_ip | cut -f1 -d' ')
PRV_NODE_0=$(grep node0 ../terraform/private_ip | cut -f1 -d' ')
PRV_NODE_1=$(grep node1 ../terraform/private_ip | cut -f1 -d' ')


# Here we update(append) the /etc/hosts file for all provisioned instances to include the private ip's of all instances
for i in $PUB_CONTROL $PUB_NODE_0 $PUB_NODE_1; do \
scp -i ../keys/tf-packer ../terraform/private_ip ansible@${i}:~;
ssh -i ../keys/tf-packer ansible@${i} "cat ~/private_ip | sudo tee -a /etc/hosts"; done


# Copy ansible.cfg(config) file to ansible users home directory
scp -i ../keys/tf-packer ../terraform/private_ip ansible@${PUB_CONTROL}:~;

# Copy inventory file to ansible users home directory
scp -i ../keys/tf-packer inventory ansible@${PUB_CONTROL}:~;

