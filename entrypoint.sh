#!/bin/bash

# Ensure that mandatory parameters are provided
if [ $# -lt 6 ]; then
    echo "Usage: $0 <environmentName> <backendBucket> <regionName> <profileName> <backendDynamoDB> <infraterraformDir>"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "Terraform is not installed. Please install Terraform to proceed."
    exit 1
fi

environmentName="$1"
backendBucket="$2"
regionName="$3"
profileName="$4"
backendDynamoDB="$5"
infraterraformDir="$6"

# Navigate to the specified terraform directory
cd "$infraterraformDir" || exit

# Initialize terraform with the provided backend configuration
terraform init -backend-config="bucket=$backendBucket" -backend-config="region=$regionName" \
-backend-config="profile=$profileName" -backend-config="dynamodb_table=$backendDynamoDB" \
-backend=true -force-copy -get=true -input=false

# Validate the terraform configuration
terraform validate

# Create a plan and save it to tfplan
terraform plan -out=tfplan

# Apply the saved plan
terraform apply tfplan