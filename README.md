# Automating Infrastructure with Terraform for GWD Fair game

![gwd_architecture_diag drawio](https://github.com/user-attachments/assets/5b383ba2-138b-48e2-8cf8-9bfc693d2434)

Table of Contents
1. Prerequisites
  1.1. Create an AWS Account and IAM Admin User
  1.2. Install AWS Command Line Interface (CLI)
  1.3. Create AWS Resources
    1.3.1. Key Pair
    1.3.2. S3 Bucket
    1.3.3. DynamoDB Table
  1.4. Install Terraform
2. Infrastructure Automation
  2.1. Introduction to Terraform
  2.2. Amazon VPC and Security Groups
  2.3. S3 Buckets
  2.4. CodePipelines
    2.4.1. CodeBuild
    2.4.2. CodeDeploy
  2.5. CloudFront
  2.6. IAM Roles
  2.7. AutoScalingGroup
  2.8. Application Load Balancer
  2.9. EC2 Instances
  2.10. Secrets Manager
3. Deploying the Infrastructure
  3.1. Clone the Repository
  3.2. Navigate to the Terraform Configuration
  3.3. Terraform Workspaces
  3.4. Initialize Terraform
  3.5. Apply Terraform Configuration
CI/CD Pipeline for the Website Front-End
4.1. BitBucket as Source Stage
4.2. CodeBuild for Build Stage
4.3. Deployment to S3 Bucket
Website Front-End Infrastructure
5.1. S3 Bucket Deployment
5.2. CloudFront Configuration
5.3. Traffic Flow (Domain, CloudFront, S3)
CI/CD Pipeline for Website Back-End
6.1. BitBucket as Source Stage
6.2. CodeBuild for Build Stage
6.3. CodeDeploy for Deployment to EC2
Auto Scaling for Back-End
7.1. Auto Scaling Group Setup
7.2. EC2 Instances in Target Group
Application Load Balancer for Back-End
8.1. Load Distribution Across EC2 Instances

## 1. Prerequisites

To deploy this solution, you need to do the following:
### 1.1  Create an AWS Account and IAM Admin User
     [Create an AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html) if you do not already have one and log in. Then create an IAM user with full admin permissions as described in [Create an Administrator](https://docs.aws.amazon.com/streams/latest/dev/setting-up.html) User. Log out and log back into the AWS console as this IAM admin user.




This repository contains Terraform configurations for managing AWS infrastructure related to the GWD Fairgame project. The configurations include setting up EC2 key pairs, S3 buckets, and DynamoDB tables.

## Prerequisites

To deploy this solution, you need to do the following: 
 
•   [Create an AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html) if you do not already have one and log in. Then create an IAM user with full admin permissions as described at [Create an Administrator](https://docs.aws.amazon.com/streams/latest/dev/setting-up.html) User. Log out and log back into the AWS console as this IAM admin user.

**NOTE:** Ensure you have two AWS accounts to proceed with this blog.

**NOTE**: This entire setup may take up to 1 hour and 30 minutes.

•   Install the AWS Command Line Interface (AWS CLI) on your local development machine and create a profile for the admin user as described at [Set Up the AWS CLI](https://docs.aws.amazon.com/streams/latest/dev/setup-awscli.html). 

•   Create a Key Pair named “gwd-fairgame-prod-eu-west-2-760669228469” in the AWS Account.

•   Create an S3 bucket named “gwd-fairgame-760669228469-eu-west-2”.

•   Then, create a DynamoDB table named “gwd-fairgame-terraform-state-lock”.

•   Install the terraform
    
    https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

## Infrastructure Automation  
 
AWS CDK is used to develop parameterized scripts to build the necessary infrastructure. These scripts include various services required for the infrastructure setup.
 
1. Amazon VPC and Security Groups
2. S3 Buckets
3. CodePipelines (CodeBuild, CodeDeploy)
4. CloudFront
5. IAM Roles
6. AutoScalingGroup
7. Application Load Balancer
8. EC2 Instances
9. Secrets Manager

## Deploying the Infrastructure  
 
1. On your development machine, clone the repo.

       git clone https://github.com/uzairmansoor/gwd-fairgame-infra-terraform.git

3. Change to the 'aws/common' directory where the Terraform configuration is located.

       cd aws/common

5. List the available workspaces.
   
       terraform workspace list

7. Select the workspace you want to deploy (e.g., prod):

       terraform workspace select prod

9. Initialize the Terraform configuration. This will download the necessary provider plugins and set up the backend.

       terraform init

11. Apply the Terraform configuration to create the infrastructure.
    
        terraform apply

This command will deploy all the infrastructure of this project including the following resources.

This is the CI/CD pipeline for the website's front-end code. "Bitbucket" is used as the source stage, and CodeBuild is used for the build stage. The build stage also handles the deployment to the S3 bucket.

<p align="center">
  <img src=https://github.com/user-attachments/assets/8b23e5e6-7c91-4d8e-9e57-460914167fef />
</p>
<p align="center">
  <b>Frontend CodePipeline</b>
</p>

This is the S3 bucket where the website's front end is deployed. All the files will appear here once the CI/CD pipeline runs successfully. When we bring up the Terraform infrastructure, this bucket will be empty.

<p align="center">
  <img src=https://github.com/user-attachments/assets/a34a0b7f-9bfb-47c8-866f-e5de5f6883b9 />
</p>
<p align="center">
  <b>Frontend S3 Bucket</b>
</p>

This is the CloudFront where the frontend's S3 bucket is set as an origin. The live domain is configured in CloudFront's domain name, and CloudFront is used as the target for the live domain. The traffic flow will be as follows: first, the traffic will come to the domain, then forward to CloudFront, and finally to the S3 bucket.

<p align="center">
  <img src=https://github.com/user-attachments/assets/71dd8142-539a-4db7-b919-8d1697e64dbf />
</p>
<p align="center">
  <b>CloudFront for Frontend</b>
</p>

This is the CI/CD pipeline for the website's back-end code. "BitBucket" is used as the Source stage, “CodeBuild” is used as the Build stage, and “CodeDeploy” is used in the Deploy stage to handle deployment to EC2.

<p align="center">
  <img src=https://github.com/user-attachments/assets/918ad10e-c696-4354-8e1f-8866500ca9bf />
</p>
<p align="center">
  <img src=https://github.com/user-attachments/assets/ab93e6b0-2f52-4746-b5fe-b80aa8a75bcf />
</p>
<p align="center">
  <b>Backend CodePipeline</b>
</p>

This is the Auto Scaling Group for the back end of the website. As the load increases, it will automatically spin up new EC2 instances and register them in the Target Group of the Application Load Balancer.

<p align="center">
  <img src=https://github.com/user-attachments/assets/71020a3c-d974-4670-8018-bc98dff6d84b />
</p>
<p align="center">
  <b>AutoScaling Group</b>
</p>

<p align="center">
  <img src=https://github.com/user-attachments/assets/12036433-e05f-4bbc-869b-d3c61c71058d />
</p>
<p align="center">
  <b>AutoScaling Group Activity</b>
</p>

<p align="center">
  <img src=https://github.com/user-attachments/assets/d8170f2c-7760-41f1-be2a-a34023104763 />
</p>
<p align="center">
  <b>AutoScaling Group </b>
</p>

This is the Application Load Balancer for the website's back-end, which will distribute traffic across the underlying EC2 instances.

<p align="center">
  <img src=https://github.com/user-attachments/assets/c76b1e64-fde6-4241-9a7c-ad50ca9bc9e2 />
</p>
<p align="center">
  <b>Application Load Balancer</b>
</p>

<p align="center">
  <img src=https://github.com/user-attachments/assets/16663ce4-5656-434c-ab74-e24e482807df />
</p>
<p align="center">
  <b>Target Group</b>
</p>

## Notes

•   Ensure that the S3 bucket name specified in the configuration is unique within the AWS region.

•   Ensure that the DynamoDB table is properly configured for state locking.

## Troubleshooting

•   If you encounter issues with state locking, verify that the DynamoDB table is correctly set up and that the AWS credentials used have appropriate permissions.
