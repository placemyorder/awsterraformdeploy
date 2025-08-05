#!/bin/bash

set -euo pipefail

# Ensure that mandatory parameters are provided
if [ $# -lt 6 ]; then
    echo "Usage: $0 <environmentName> <backendBucket> <regionName> <profileName> <backendDynamoDB> <infraterraformDir> [displayOutput]"
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
displayOutput="${7:-false}"  # Default to false if not provided

# Navigate to the specified terraform directory
cd "$infraterraformDir" || exit

# Initialize terraform with the provided backend configuration
terraform init -backend-config="bucket=$backendBucket" \
               -backend-config="region=$regionName" \
               -backend-config="profile=$profileName" \
               -backend-config="dynamodb_table=$backendDynamoDB" \
               -backend=true -force-copy -get=true -input=false

# Validate the terraform configuration
terraform validate

# Create a plan and save it to tfplan
terraform plan -out=tfplan

# Apply the saved plan
terraform apply tfplan

# Export Terraform outputs to GitHub Actions outputs
echo "Exporting Terraform outputs..."
output_json=$(terraform output -json)

if [ "$displayOutput" = "true" ]; then
    echo "Terraform outputs: $output_json"
fi

# Check if we're running in GitHub Actions
if [ -z "$GITHUB_OUTPUT" ]; then
    echo "Warning: GITHUB_OUTPUT environment variable not set. Outputs will not be exported to GitHub Actions."
    exit 0
fi

if [[ "$output_json" != "{}" && -n "$output_json" ]]; then
    echo "$output_json" | jq -r 'to_entries[] | "\(.key)=\(.value.value)"' >> "$GITHUB_OUTPUT"
    echo "Successfully exported $(echo "$output_json" | jq 'keys | length') outputs to GitHub Actions."
else
    echo "No Terraform outputs found."
fi