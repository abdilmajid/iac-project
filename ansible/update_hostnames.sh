#!/bin/bash

# This script will update the hostname for given machine
# SO instead of [ansible@ip-10-... ~] => [ansible@CONTROL ~] or [ansible@NODE1 ~] ...etc

# grabs the public ip address and assigns to variable
CONTROL=$(grep control ../terraform/public_ip | cut -f1 -d' ')
NODE0=$(grep node0 ../terraform/public_ip | cut -f1 -d' ')
NODE1=$(grep node1 ../terraform/public_ip | cut -f1 -d' ')

# Check that ansible users added to each machine, and files copied to control node 
for i in $CONTROL $NODE0 $NODE1; 
do
case ${i} in
  $CONTROL)
    $(ssh -i ../keys/tf-packer ansible@${i} 'sudo hostnamectl hostname control')
    ;;
  $NODE0)
    $(ssh -i ../keys/tf-packer ansible@${i} 'sudo hostnamectl hostname node0')
    ;;
  $NODE1)
    $(ssh -i ../keys/tf-packer ansible@${i} 'sudo hostnamectl hostname node1')
    ;;
  *)
    echo "Somthing went wrong"
    ;;
esac
done

# CHECK
echo "CONTROL Hostname: $(ssh -i ../keys/tf-packer ansible@${CONTROL} 'hostnamectl hostname')";
echo "NODE0 Hostname: $(ssh -i ../keys/tf-packer ansible@${NODE0} 'hostnamectl hostname')"
echo "NODE1 Hostname: $(ssh -i ../keys/tf-packer ansible@${NODE1} 'hostnamectl hostname')"
