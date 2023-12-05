#!/bin/bash
sudo dnf update -y
sudo dnf install \
https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
sudo dnf install ansible -y
