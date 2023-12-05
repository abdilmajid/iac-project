#!/bin/bash
echo install epel package
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release epel-next-release -y
echo install ansible
sudo yum install ansible -y

