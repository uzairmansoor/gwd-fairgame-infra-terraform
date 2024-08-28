provider "aws" {
  region = "eu-west-1"
  # profile = "xybion-dev"
  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Project     = "gwd-fairgame"
      Environment = "${terraform.workspace}"
    }
  }
}

terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
  backend "s3" {
    # bucket         = "gwd-fairgame-355986150263-eu-west-1"
    # key            = "common/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "gwd-fairgame-terraform-common-state-lock"
  }
}

# module "vpc" {
#   source    = "./vpc"
# }