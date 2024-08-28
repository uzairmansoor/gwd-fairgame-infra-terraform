# Terraform Infrastructure for GWD Fairgame

This repository contains Terraform configurations for managing AWS infrastructure related to the GWD Fairgame project. The configurations include setting up EC2 key pairs, S3 buckets, and DynamoDB tables.

## Prerequisites

•   Terraform: Version >= 1.8.0, < 2.0.0

•   AWS CLI: Configured with appropriate IAM permissions

## Setup Instructions

1. Clone the Repository

First, clone this repository to your local machine:

    git clone https://github.com/uzairmansoor/gwd-fairgame-infra-terraform.git

2. Navigate to the Directory

Change to the 'aws/common' directory where the Terraform configuration is located:

    cd aws/common

3. Initialize Terraform

Initialize the Terraform configuration. This will download the necessary provider plugins and set up the backend:

    terraform init

4. Select a Workspace

List the available workspaces:

    terraform workspace list

5. Select the workspace you want to deploy (e.g., dev):

    terraform workspace select dev

6. Apply the Configuration

Apply the Terraform configuration to create the infrastructure:

    terraform apply

## Resources

•   EC2 Key Pair: A key pair will be created for each workspace.

•   S3 Bucket: An S3 bucket will be created using the name specified in main.tf.

•   DynamoDB Table: A DynamoDB table with a sort key named LockID will be created to manage state locking.

## Notes

•   Ensure that the S3 bucket name specified in the configuration is unique within the AWS region.

•   Ensure that the DynamoDB table is properly configured for state locking.

## Troubleshooting

•   If you encounter issues with state locking, verify that the DynamoDB table is correctly set up and that the AWS credentials used have appropriate permissions.