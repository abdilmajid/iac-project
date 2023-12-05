#!/bin/bash
sudo useradd ansible

# Generate ssh key that will be compied to managed nodes
# allow sudo access without entering password
echo "ansible  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible