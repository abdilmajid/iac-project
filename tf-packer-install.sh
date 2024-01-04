#!/bin/bash
# Script to install Terraform and Packer on Ubuntu/Debian, Centos/Redhat and AWS Linux 
# This checks OS, then assings variable "OS"
OS=$(grep -i ^name /etc/os-release |cut -f2 -d"="|sed 's/"//g')

# check if packer and terraform already installed
CHECK_PKR=$(which packer 2>/dev/null)
CHECK_PKR=$(echo $?)

CHECK_TF=$(which terraform 2>/dev/null)
CHECK_TF=$(echo $?)


# -- Below terraform and packer packages installed based on current OS
# Check if packages already installed
if [ $CHECK_PKR -eq 0 ] && [ $CHECK_TF -eq 0 ]; then
	echo "Terreform and Packer already installed"
# installs terraform and packer on Debian/Ubuntu
elif [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ]; then
	wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	# jq works with json data, not installed by default in ubuntu
	sudo apt update && sudo apt install terraform packer jq

# installs terraform and packer on CentOS/RHEL
elif [[ $OS = "Red Hat Enterprise Linux" ]] || [[ $OS = "CentOS Stream" ]] || [[ $OS = "CentOS Linux" ]] ; then
	sudo yum install -y yum-utils
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
	sudo yum -y install terraform packer jq
# installs terraform/packer on AMZ Linux OS
elif [[ $OS = "Amazon Linux" ]]; then
	sudo yum install -y yum-utils shadow-utils
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
	sudo yum -y install terraform packer jq
else
	echo "Sorry, cant run this script"
fi


# -- Check that everything installed correctly
# Packer version
echo 
echo " ==== PACKER VERSION ==== "
packer version
echo  "-------------------------"
echo 
# Terraform Version
echo " ==== TERRAFORM VERSION ==== "
terraform version
echo  "-------------------------"
echo 

# Set up tab completion for Packer 
packer -autocomplete-install;
# Set up tab completion for terraform
terraform -install-autocomplete;


###################################
#|NOTE: This will generate the ssh-key pairs and store in keys dir
# Comment this out if using previously generated keys or want 
# to manually generate keys 
if [ ! -f ./keys/tf-packer ]; then
	mkdir keys
	ssh-keygen -t rsa -N "" -f ./keys/tf-packer
else
	echo "tf-packer key pairs already generated"
fi
###################################

# applies packer/terraform tab completion without having to open a seperate shell
exec bash;
