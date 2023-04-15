# networking module main file


# create a new vpc
resource "aws_vpc" "vpc_example" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}

#create internet gateway
resource "aws_internet_gateway" "igw-example" {
  vpc_id = aws_vpc.vpc_example.id
}

#create a public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.vpc_example.id
  cidr_block              = var.public_subnet
  map_public_ip_on_launch = true
  availability_zone       = var.azs
  tags = {
    Name = "public-subnet"
  }
}

#create public route table
resource "aws_route_table" "RT-public" {
  vpc_id = aws_vpc.vpc_example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-example.id
  }
  tags = {
    Name = "RT-public"
  }
}

#associate the public subnet with the route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_ud = aws_route_table.RT-public.id
}


# Secuity Group to allow public access.

resource "aws_security_group" "letweb" {
  name        = "letweb"
  description = "allow ssh and http"
  vpc_id      = aws_vpc.vpc-tf.id
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
