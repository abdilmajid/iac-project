#!/bin/bash

# This script returns 
# 1) the /etc/hosts file for each instance
# 2) the user and group id for the ansible user
# 3) the public ip for each instance 

# grabs the public ip address and assigns to variable
PUB_CONTROL=$(grep control ../terraform/public_ip | cut -f1 -d' ')
PUB_NODE_0=$(grep node0 ../terraform/public_ip | cut -f1 -d' ')
PUB_NODE_1=$(grep node1 ../terraform/public_ip | cut -f1 -d' ')

# Check that ansible users added to each machine, and files copied to control node 
for i in $PUB_CONTROL $PUB_NODE_0 $PUB_NODE_1; 
do
case ${i} in
  $PUB_CONTROL)
    echo "CONTROL(${i}): $(ssh -i ../keys/tf-packer ansible@${i} 'id ansible; ls; cat /etc/hosts')"
    echo "-----------"
    ;;
  $PUB_NODE_0)
    echo "NODE0(${i}): $(ssh -i ../keys/tf-packer ansible@${i} 'id ansible; ls; cat /etc/hosts')"
    echo "-----------"
    ;;
  $PUB_NODE_1)
    echo "NODE1(${i}): $(ssh -i ../keys/tf-packer ansible@${i} 'id ansible; ls; cat /etc/hosts')"
    echo "-----------"
    ;;
  *)
    echo "Somthing went wrong"
    ;;
esac
done