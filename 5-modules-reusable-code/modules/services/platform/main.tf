# Template

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

# Create a new VPC named vpc-example.
resource "aws_vpc" "vpc-example" {
  cidr_block = var.cidr_block
  tags       = { Name = "${var.vpc_name}" }
}
# Create an Internet Gateway.
resource "aws_internet_gateway" "igw-example" {
  vpc_id = aws_vpc.vpc-example.id
  tags   = { Name = "${var.igw_name}" }
}

# Create public route table.
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc-example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-example.id
  }
  tags = { Name = "public access route table" }
}

# Create one to many subnets with public IP option.
resource "aws_subnet" "subnet-public-example" {
  count                   = length(var.public_cidr)
  vpc_id                  = aws_vpc.vpc-example.id
  cidr_block              = var.public_cidr[count.index]
  availability_zone       = var.az_pub[count.index]
  map_public_ip_on_launch = "true"
  tags                    = { Name = "subnet-public-${count.index + 1}" }
}

# Associate public subnets with Route Table
resource "aws_route_table_association" "public_access" {
  count          = length(var.public_cidr)
  subnet_id      = aws_subnet.subnet-public-example[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

# Configure Security Group allow public.
resource "aws_security_group" "webservers" {
  name        = "webservers"
  description = "allow ssh and http"
  vpc_id      = aws_vpc.vpc-example.id
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}


# Deploy one to many EC2 instances in public subnets
resource "aws_instance" "EC2-terraformed" {
  count           = length(var.public_cidr)
  ami             = var.ami
  instance_type   = var.ec2_type
  key_name        = var.key
  security_groups = [aws_security_group.webservers.id]
  subnet_id       = aws_subnet.subnet-public-example[count.index].id
  user_data       = file("user-data.sh")
  tags            = { Name = "${var.ec2_name}-${count.index + 1}" }
}