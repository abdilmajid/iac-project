#!/bin/bash
sudo useradd ansible


# Add ansible user to sudoers file
# echo "ansible  ALL=(ALL)  NOPASSWD:ALL" >> /etc/sudoers.d/ansible