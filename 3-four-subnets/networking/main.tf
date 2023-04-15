# main.tf at networking level. root/networking/main.tf

# Create a new VPC

resource "aws_vpc" "vpc-tf" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc-tf"
  }
}

# Create public subnets

resource "aws_subnet" "SN-public" {
  vpc_id                  = aws_vpc.vpc-tf.id
  count                   = var.counter
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = ["us-east-1a", "us-east-1b"][count.index]
  tags = {
    Name = "SN-public-${count.index + 1}"
  }
}

# Create private subnets

resource "aws_subnet" "SN-private" {
  vpc_id            = aws_vpc.vpc-tf.id
  count             = var.counter
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = ["us-east-1c", "us-east-1d"][count.index]
  tags = {
    Name = "SN-private-${count.index}+ 1"
  }
}

# Create internet gateway

resource "aws_internet_gateway" "igw-vpc-tf" {
  vpc_id = aws_vpc.vpc-tf.id
  tags = {
    Name = "igw=vpc-tf"
  }
}

# Create public routing table

resource "aws_route_table" "RT-Public" {
  vpc_id = aws_vpc.vpc-tf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-tf.id
  }
  tags = {
    Name = "public access route table"
  }
}

# Associate public subnet with public route table

resource "aws_route_table_association" "RT-public" {
  count          = var.counter
  subnet_id      = aws_subnet.SN-public.*.id[count.index]
  route_table_id = aws_route_table.RT-Public.id
}


# Secuity Group to allow public access.

resource "aws_security_group" "tf-web" {
  name        = "tf-web"
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

# Deploy one EC2 instance in each public subnet.

resource "aws_instance" "EC2-instance-public" {
  count             = var.counter
  ami               = "ami-047a51fa27710816e"
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.SN-public.*.id[count.index]
  availability_zone = ["us-east-1a", "us-east-1b"][count.index]
  user_data         = file("./networking/install_apache.sh")
  security_groups   = [aws_security_group.tf-web.id]
  key_name          = "kris_desktop"
  tags = {
    Name = "VM-${count.index + 1}"
  }
}

# Create two EC2 instances, one per private subnet

resource "aws_instance" "EC2-instance-private" {
  count             = var.counter
  ami               = "ami-047a51fa27710816e"
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.SN-private.*.id[count.index]
  availability_zone = ["us-east-1c", "us-east-1d"][count.index]
  key_name          = "kris_desktop"
  tags = {
    Name = "EC2-${count.index + 1}"
  }

}