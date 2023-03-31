# Create VPC

resource "aws_vpc" "vpc-a" {
    cidr_block = "192.168.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = { Name = "vpc_a"}
}

resource "aws_internet_gateway" "igw-vpc-a" {
    vpc_id = aws_vpc.vpc-a.id
    tags    = { Name = "igw-vpc-a" }
}