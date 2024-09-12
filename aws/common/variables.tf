##########################################
# AWS Provider
##########################################

variable "account_id" {
  type        = number
  description = "AWS Account ID"
  default     = 760669228469 #355986150263 #760669228469
}

variable "project" {
  type        = string
  description = "Project Name"
  default     = "gwd-fairgame"
}

variable "location" {
  type        = string
  description = "Amazon Region Name"
  default     = "eu-west-2"
}

##########################################
# VPC
##########################################

variable "cidr" {
  type        = map(string)
  description = "Classless Inter-Domain Routing, it is the mask of the VPC network"
  default = {
    dev    = "10.3.0.0/16"
    stage  = "10.4.0.0/16"
    prod   = "10.6.0.0/16"
  }
}

variable "public_subnet_1" {
  type        = map(string)
  description = "public-1a"
  default = {
    dev    = "10.3.0.0/20"
    stage  = "10.4.0.0/20"
    prod = "10.6.1.0/24"
  }
}

variable "zone_subnet_1" {
  type        = string
  description = "zone subnet 1"
  default     = "eu-west-2a"
}

variable "public_subnet_2" {
  type        = map(string)
  description = "public-1b"
  default = {
    dev    = "10.3.16.0/20"
    stage  = "10.4.16.0/20"
    prod = "10.6.2.0/24"
  }
}

variable "zone_subnet_2" {
  type        = string
  description = "zone subnet 2"
  default     = "eu-west-2b"
}

variable "private_subnet_1" {
  type        = map(string)
  description = "private-1"
  default = {
    dev    = "10.3.128.0/20"
    stage  = "10.4.128.0/20"
    prod = "10.6.3.0/24"
  }
}

variable "private_subnet_2" {
  type        = map(string)
  description = "private-2"
  default = {
    dev    = "10.3.144.0/20"
    stage  = "10.4.144.0/20"
    prod = "10.6.4.0/24"
  }
}

##########################################
# Application Load Balancer
##########################################

variable "lb_target_group_port" {
  type        = number
  description = "Port to access the backend"
  default     = 3000
}

variable "lb_listener_protocol" {
  type        = string
  description = "Protocol to access the backend"
  default     = "HTTP"
}

##########################################
# S3 (Simple Storage Service)
##########################################

variable "bucket_name" {
  type        = string
  description = "bucket Name"
  default     = "frontend"
}
variable "bucket_acl" {
  type        = string
  description = "value for bucket Acl"
  default     = "private"
}

variable "bucket_versioning" {
  type        = string
  description = "value for the bucket versioning"
  default     = "Enabled"
}

##########################################
# CloudFront
##########################################

# variable "bucket_domain" {
#   type        = string
#   description = "bucket domain name"
# }
# variable "bucket_log" {
#   type        = string
#   description = "bucket name for the logging"
# }

# variable "bucket_id" {
#   type        = string
#   description = "Id of bucket"
# }
# variable "bucketArn" {
#   type        = string
#   description = "Arn of bucket"
# }
# variable "cloudfrontArn" {
#   type        = string
#   description = "Arn of cloufrontArn"
# }

##########################################
# Code Pipeline
##########################################

# variable "codebuildProjectName" {
#   type        = string
#   description = "Name of codebuild project"
# }
# variable "codepipelineRole" {
#   type        = string
#   description = "Name of codebuild project"
# }
# variable "bitbucketArn" {
#   type        = string
#   description = "Arn of the code starconnection for bit bucket"
# }
# variable "s3Artifactbucket" {
#   type        = string
#   description = "Name of s3 bucket to store artifacts"
# }
# variable "prodBucketID" {
#   type        = string
#   description = "Name of s3 bucket for deployment"
# }
variable "sourceConnectionArn" {
  type        = string
  description = "Codestar connection ARN" #Manually create this connection and pass the ARN here as it requires manual approval.
  default     = "arn:aws:codestar-connections:eu-west-2:760669228469:connection/28d47e66-649f-4b58-a349-153a14c8d46c"
}
variable "bitbucketRepo" {
  type        = string
  description = "Name of bitbucket repo for deployment"
  default     = "fairgame-registration-gateway"
}
variable "repoBranchName" {
  type        = string
  description = "Name of the repository branch"
  default     = "develop"
}
variable "bitbucketAccount" {
  type        = string
  description = "Name of bitbucket repo for deployment"
  default     = "gwdmedia"
}
# variable "codebuildRole" {
#   type        = string
#   description = "The ARN of code build role"
# }