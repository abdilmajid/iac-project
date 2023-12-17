#!/bin/bash

# This script will be used by packer to update the "variables.tf" file inside the terraform directory
# the idea is that after packer ami image is created, the variable that corresponds to the image("ami-control","ami-managed") will be updated automatically

AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ":" -f2)
AMI_NAME=$(jq -r '.builds[-1].name' manifest.json)


if [ $AMI_NAME == "managed_centos9" ]; then
	sed -i "/ami_managed/ {n; :a; /ami-/! {N; ba;}; s/\"ami-.*\"/\"${AMI_ID}\"/; :b; n; $! bb}" ../../terraform/variables.tf
else
  echo "Something went wrong"
fi


