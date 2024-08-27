##########################################
# Virtual Private Cloud VPC
##########################################


# VPC (Virtual Private Cloud)
# --------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr[terraform.workspace]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project}-${terraform.workspace}-vpc"
  }
}

# Internet Gateway
# --------------------------------------
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-${terraform.workspace}-igw"
  }
}

# Public Subnet
# --------------------------------------
module "public_subnets" {
  source          = "./modules/aws_vpc_public_subnets"
  vpc_id          = aws_vpc.vpc.id
  gateway_id      = aws_internet_gateway.gateway.id
  environment     = terraform.workspace
  public_subnet_1 = var.public_subnet_1[terraform.workspace]
  public_subnet_2 = var.public_subnet_2[terraform.workspace]
  zone_subnet_1   = var.zone_subnet_1
  zone_subnet_2   = var.zone_subnet_2
}

# Elastic IP
# --------------------------------------
resource "aws_eip" "eip1" {
  domain = "vpc"
}

# NAT Gateway
# --------------------------------------
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = module.public_subnets.subnet_1
  depends_on = [aws_internet_gateway.gateway]
}

# Private Subnet
# --------------------------------------
module "private_subnets" {
  source           = "./modules/aws_vpc_private_subnets"
  vpc_id           = aws_vpc.vpc.id
  environment      = terraform.workspace
  private_subnet_1 = var.private_subnet_1[terraform.workspace]
  private_subnet_2 = var.private_subnet_2[terraform.workspace]
  zone_subnet_1    = var.zone_subnet_1
  zone_subnet_2    = var.zone_subnet_2
  nat_gateway_id   = aws_nat_gateway.nat1.id
  depends_on       = [aws_nat_gateway.nat1]
}