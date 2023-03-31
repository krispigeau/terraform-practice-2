# Make VPC

resource "aws_vpc" "vpc-a" {
    cidr_block = "192.168.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = { Name = "vpc_a"}
}

# Make internet gateway

resource "aws_internet_gateway" "igw-vpc-a" {
    vpc_id = aws_vpc.vpc-a.id
    tags    = { Name = "igw-vpc-a" }
}

# Make public routing table with default route pointing to igw

resource "aws_route_table" "RT-public" {
    vpc_id = aws_vpc.vpc-a.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw-vpc-a.id
    }
    tags = { Name = "public access routing table" }
}

# Make public subnet

resource "aws_subnet" "SN-public-1" {
    vpc_id = aws_vpc.vpc-a.id
    cidr_block = "192.168.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = { Name = "SN-public-1"}
}