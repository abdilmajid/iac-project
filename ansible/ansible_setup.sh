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

# First check if already appened contents to /etc/hosts
CHK_HOSTS=$(ssh -i ../keys/tf-packer ansible@$PUB_CONTROL "grep control /etc/hosts" 2>/dev/null)
CHK_HOSTS=$(echo $?)
# here we will assume that if "control" private ip already exists in hosts file, then contents have been appended 
if [ $CHK_HOSTS -eq 0 ]; then
  echo "hosts file already appened"
else
  # Here we update(append) the /etc/hosts file for all provisioned instances to include the private ip's of all instances
  for i in $PUB_CONTROL $PUB_NODE_0 $PUB_NODE_1; do \
  scp -i ../keys/tf-packer ../terraform/private_ip ansible@${i}:/tmp;
  # check if ip's already appended to hosts file
  ssh -i ../keys/tf-packer ansible@${i} "cat /tmp/private_ip | sudo tee -a /etc/hosts"; done
fi


# Copy ansible.cfg(config) and inventory file to ansible users home directory
for i in ansible.cfg inventory; 
do scp -i ../keys/tf-packer ${i} ansible@${PUB_CONTROL}:~; 
done


# Check that ansible users added to each machine, and files copied to control node 
# also shows 
for i in $PUB_CONTROL $PUB_NODE_0 $PUB_NODE_1; 
do
case ${i} in
  $PUB_CONTROL)
    echo "CONTROL(${i}): $(ssh -i ../keys/tf-packer ansible@${i} 'id ansible; ls')"
    ;;
  $PUB_NODE_0)
    echo "NODE0(${i}): $(ssh -i ../keys/tf-packer ansible@${i} 'id ansible; ls')"
    ;;
  $PUB_NODE_1)
    echo "NODE1(${i}): $(ssh -i ../keys/tf-packer ansible@${i} 'id ansible; ls')"
    ;;
  *)
    echo "Somthing went wrong"
    ;;
esac
done
