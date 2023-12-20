#!/bin/bash

# Check if ami-control exists
CHK_PKR_CTRL=$(jq -r '.builds[-1].artifact_id' images/ami-control/manifest.json | cut -d ":" -f2 2>/dev/null)
CHK_PKR_CTRL=$(echo $?)

# Check if ami-managed exists
CHK_PKR_MNG=$(jq -r '.builds[-1].artifact_id' images/ami-managed/manifest.json | cut -d ":" -f2 2>/dev/null)
CHK_PKR_MNG=$(echo $?)

# If packer image already built then skips to provisioning with terraform
if [ $CHK_PKR_CTRL -eq 0 ] && [ $CHK_PKR_MNG -eq 0 ]; then
  echo "ami images already created";
else
# Packer initialized and images built concurrently,
#|NOTE: the (cd ..) executes command relative to given directory, and "&" runs process in background
(cd images/ami-control/ && packer init . && packer build .)& 
(cd images/ami-managed/ && packer init . && packer build .)& 
# the "wait" command will wait until previous process done before going to next line 
wait
fi

# terraform initialized 
(cd terraform/ && terraform init && terraform validate) 
(cd terraform/ && terraform plan && terraform apply --auto-approve);

echo done;

