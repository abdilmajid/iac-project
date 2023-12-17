#!/bin/bash


# Packer initialized and images built in parallel,
#|NOTE: the (cd ..) executes command relative to given directory, and "&" runs process in background
(cd images/ami-control/ && packer init . && packer build .)& 
(cd images/ami-managed/ && packer init . && packer build .)& 
# the "wait" command will wait until process previous process done before going to next line 
wait

# # terraform initialized 
# (cd terraform/ && terraform init && terraform validate && terraform plan)