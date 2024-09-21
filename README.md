# Terraform Infrastructure for GWD Fairgame

This repository contains Terraform configurations for managing AWS infrastructure related to the GWD Fairgame project. The configurations include setting up EC2 key pairs, S3 buckets, and DynamoDB tables.

## Prerequisites

To deploy this solution, you need to do the following: 
 
•   Create an AWS account if you do not already have one and log in. Then create an IAM user with full admin permissions as described in Create an Administrator User. Log out and log back into the AWS console as this IAM admin user.
NOTE: Ensure you have two AWS accounts to proceed with this blog.

•   Install the AWS Command Line Interface (AWS CLI) on your local development machine and create a profile for the admin user as described in Set Up the AWS CLI.

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

       git clone [{public_repository_url} ](https://github.com/uzairmansoor/gwd-fairgame-infra-terraform.git)

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

    ![image](https://github.com/user-attachments/assets/8b23e5e6-7c91-4d8e-9e57-460914167fef)

This is the S3 bucket where the website's front end is deployed. All the files will appear here once the CI/CD pipeline runs successfully. When we bring up the Terraform infrastructure, this bucket will be empty.

![image](https://github.com/user-attachments/assets/a34a0b7f-9bfb-47c8-866f-e5de5f6883b9)

This is the CloudFront where the frontend's S3 bucket is set as an origin. The live domain is configured in CloudFront's domain name, and CloudFront is used as the target for the live domain. The traffic flow will be as follows: first, the traffic will come to the domain, then forward to CloudFront, and finally to the S3 bucket.

![image](https://github.com/user-attachments/assets/71dd8142-539a-4db7-b919-8d1697e64dbf)

This is the CI/CD pipeline for the website's back-end code. "BitBucket" is used as the Source stage, “CodeBuild” is used as the Build stage, and “CodeDeploy” is used in the Deploy stage to handle deployment to EC2.

![image](https://github.com/user-attachments/assets/918ad10e-c696-4354-8e1f-8866500ca9bf)
![image](https://github.com/user-attachments/assets/ab93e6b0-2f52-4746-b5fe-b80aa8a75bcf)

This is the Auto Scaling Group for the back end of the website. As the load increases, it will automatically spin up new EC2 instances and register them in the Target Group of the Application Load Balancer.

![image](https://github.com/user-attachments/assets/71020a3c-d974-4670-8018-bc98dff6d84b)
![image](https://github.com/user-attachments/assets/12036433-e05f-4bbc-869b-d3c61c71058d)
![image](https://github.com/user-attachments/assets/d8170f2c-7760-41f1-be2a-a34023104763)

This is the Application Load Balancer for the website's back-end, which will distribute traffic across the underlying EC2 instances.

![image](https://github.com/user-attachments/assets/c76b1e64-fde6-4241-9a7c-ad50ca9bc9e2)
![image](https://github.com/user-attachments/assets/16663ce4-5656-434c-ab74-e24e482807df)

## Notes

•   Ensure that the S3 bucket name specified in the configuration is unique within the AWS region.

•   Ensure that the DynamoDB table is properly configured for state locking.

## Troubleshooting

•   If you encounter issues with state locking, verify that the DynamoDB table is correctly set up and that the AWS credentials used have appropriate permissions.
