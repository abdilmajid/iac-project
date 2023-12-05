#!/bin/bash
# allow sudo access without entering password
echo "ansible  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible