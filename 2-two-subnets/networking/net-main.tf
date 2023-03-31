# Create VPC

resource "aws_vpc" "vpc_a" {
    cidr_block = "192.168.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = { Name = "vpc_a"}
}