# -------------------------------------
# Terraform configuration
# -------------------------------------
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

/*******************************
* VPC
*******************************/
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project}-${var.env}-vpc"
  }
}

/*******************************
* Subnet - public
*******************************/
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[0]
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "${var.project}-${var.env}-subnet-public-${var.availability_zones[0]}"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[1]
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "${var.project}-${var.env}-subnet-public-${var.availability_zones[1]}"
  }
}

/******************************
 * Subnet - private
 ******************************/
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[0]
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "${var.project}-${var.env}-subnet-private-${var.availability_zones[0]}"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[1]
  cidr_block        = "10.0.4.0/24"
  tags = {
    Name = "${var.project}-${var.env}-subnet-private-${var.availability_zones[1]}"
  }
}

/******************************
 * Subnet - isolated
 ******************************/
resource "aws_subnet" "isolated1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[0]
  cidr_block        = "10.0.5.0/24"
  tags = {
    Name = "${var.project}-${var.env}-subnet-isolated-${var.availability_zones[0]}"
  }
}
resource "aws_subnet" "isolated2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[1]
  cidr_block        = "10.0.6.0/24"
  tags = {
    Name = "${var.project}-${var.env}-subnet-isolated-${var.availability_zones[1]}"
  }
}

/******************************
 * InternetGateway
 ******************************/
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.env}-igw"
  }
}

/******************************
 * Elastic IP
 ******************************/
resource "aws_eip" "for_nat" {
  domain = "vpc"
  tags = {
    Name = "${var.project}-${var.env}-eip-for-nat-${var.availability_zones[0]}"
  }
}

/******************************
 * NAT
 ******************************/
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.for_nat.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "${var.project}-${var.env}-nat-${var.availability_zones[0]}"
  }
  depends_on = [aws_internet_gateway.main]
}

/******************************
 * RouteTable
 ******************************/
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.env}-rtb-public"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.env}-rtb-private"
  }
}
resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.env}-rtb-isolated"
  }
}

/******************************
 * Route
 ******************************/
resource "aws_route" "to_igw" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
}
resource "aws_route" "to_nat" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.nat.id
}

/******************************
 * SubnetRouteTableAssociation
 ******************************/
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "isolated1" {
  subnet_id      = aws_subnet.isolated1.id
  route_table_id = aws_route_table.isolated.id
}
resource "aws_route_table_association" "isolated2" {
  subnet_id      = aws_subnet.isolated2.id
  route_table_id = aws_route_table.isolated.id
}

/******************************
 * SecurityGroup - public
 ******************************/
resource "aws_security_group" "public" {
  name        = "${var.project}-${var.env}-sg-public"
  description = "public security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-public"
  }
}

/******************************
 * SecurityGroup - private
 ******************************/
resource "aws_security_group" "private" {
  name        = "${var.project}-${var.env}-sg-private"
  description = "private security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    self            = true
    security_groups = [aws_security_group.public.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-private"
  }
}

/******************************
 * SecurityGroup - isolated
 ******************************/
resource "aws_security_group" "isolated" {
  name        = "${var.project}-${var.env}-sg-isolated"
  description = "isolated security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    self            = true
    security_groups = [aws_security_group.private.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-isolated"
  }
}
