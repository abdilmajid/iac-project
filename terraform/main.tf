/*
|Note: Credential stored in env variables
- so we don't need to include the aws provider block/file because terraform will grab it from env
% export AWS_ACCESS_KEY_ID="anaccesskey"
% export AWS_SECRET_ACCESS_KEY="asecretkey"
% export AWS_REGION="us-east-1"
*/

# This provisions the control node 
resource "aws_instance" "control" {
  ami  = "ami-023c11a32b0207432" # RHEL9 
  instance_type = "t2.micro"
  # if no default subnet, then we can use setup_id
  # make sure to use correct subnet
  subnet_id = "subnet-064789520be471d06"
}


