#!/bin/bash
# Ask the user for their name

echo What is the AWS Access Key you want to use?
read access_key

echo What is the AWS Secret Key you want to use?
read secret_key

echo What is the AWS region you want to use?
read region

echo What is the enviroment - dev,stag,prod
read env

echo  -e "access_key = \"$access_key\"\n\
secret_key = \"$secret_key\"\n\
region     = \"$region\"\n\
env        = \"$env\"" > iac/env.tfvars

cd iac/
wget https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip
unzip terraform_1.0.9_linux_amd64.zip
./terraform init
./terraform apply -var-file=env.tfvars