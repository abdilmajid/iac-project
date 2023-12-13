#!/bin/bash

# grabs the public ip address and assigns to variable
PUB_CONTROL=$(grep control ./terraform/public_ip | cut -f1 -d' ')
PUB_NODE_0=$(grep node_0 ./terraform/public_ip | cut -f1 -d' ')
PUB_NODE_1=$(grep node_1 ./terraform/public_ip | cut -f1 -d' ')

# grabs the private ip address and assigns to variable
PRV_CONTROL=$(grep control ./terraform/private_ip | cut -f1 -d' ')
PRV_NODE_0=$(grep node_0 ./terraform/private_ip | cut -f1 -d' ')
PRV_NODE_1=$(grep node_1 ./terraform/private_ip | cut -f1 -d' ')


# copies host_ip file created in terraform local_file resource to the given instance
# then appends content to /etc/hosts
for i in $PUB_CONTROL $PUB_NODE_0 $PUB_NODE_1; do \
scp -i ./keys/tf-packer ./terraform/private_ip ansible@${i}:~;
ssh -i ./keys/tf-packer ansible@${i} "cat ~/private_ip | sudo tee -a /etc/hosts"; done
