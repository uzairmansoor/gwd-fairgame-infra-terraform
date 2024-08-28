provider "aws" {
  region = "eu-west-2"
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
    bucket         = "gwd-fairgame-760669228469-eu-west-2"
    key            = "common/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "gwd-fairgame-terraform-state-lock"
  }
}