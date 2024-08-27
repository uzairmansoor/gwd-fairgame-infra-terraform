resource "aws_subnet" "private_subnet_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_1
  availability_zone = var.zone_subnet_1
  tags = {
    Name = "${var.project}-${terraform.workspace}-private_subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_2
  availability_zone = var.zone_subnet_2
  tags = {
    Name = "${var.project}-${terraform.workspace}-private_subnet-2"
  }
}

# Create a route table for the private subnets
resource "aws_route_table" "private_route" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }
  tags = {
    Name = "${var.project}-${terraform.workspace}-private-private-route"
  }
}

# Associate the subnets with the route table
resource "aws_route_table_association" "subnet_1_route_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route.id
}
resource "aws_route_table_association" "subnet_2_route_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route.id
}