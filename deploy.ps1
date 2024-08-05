param(
    [parameter(Mandatory=$true)]
    [string]$environmentName,

    [parameter(Mandatory=$true)]
    [string]$backendBucket,

    [parameter(Mandatory=$true)]
    [string]$regionName,

    [parameter(Mandatory=$true)]
    [string]$profileName,

    [parameter(Mandatory=$true)]
    [string]$backendDynamoDB,
    
    [parameter(Mandatory=$true)]
    [string]$infraterraformDir
)

Set-Location $infraterraformDir

terraform init -backend-config="bucket=$backendBucket" -backend-config="region=$regionName" `
-backend-config="profile=$profileName" -backend-config="dynamodb_table=$backendDynamoDB" `
-backend=true -force-copy -get=true -input=false

terraform validate

terraform plan -out=tfplan

terraform apply tfplan