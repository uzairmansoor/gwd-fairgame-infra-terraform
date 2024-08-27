resource "aws_subnet" "subnet_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_1
  availability_zone = var.zone_subnet_1
  tags = {
    Name = "${var.project}-${terraform.workspace}-public-subnet-1"
  }
}

# Public subnet in zone 2
resource "aws_subnet" "subnet_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_2
  availability_zone = var.zone_subnet_2
  tags = {
    Name = "${var.project}-${terraform.workspace}-public-subnet-2"
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public_route" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  tags = {
    Name = "${var.project}-${terraform.workspace}-public-route"
  }
}

# Associate the subnets with the route table
resource "aws_route_table_association" "subnet_1_route_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_route.id
}
resource "aws_route_table_association" "subnet_2_route_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public_route.id
}