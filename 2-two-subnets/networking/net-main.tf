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

# Make private subnet

resource "aws_subnet" "SN-private-1" {
    vpc_id = aws_vpc.vpc-a.id
    cidr_block = "192.168.2.0/24"
    availability_zone = "us-east-1b"
    tags = { Name = "SN-private-1"}
}

# Association of public subnet with public routing table

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.SN-public-1.id
    route_table_id = aws_subnet.SN-public-1.id
}

# Configuration of security group

resource "aws_security_group" "permit-web" {
  name = "permit-web"
  description = "allow web traffic and SSH"
  vpc_id = aws_vpc.vpc-a.id
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"   
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"   
  }
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"   
  }
}

# Create EC2 instance in the public subnet

resource "aws_instance" "VM-01" {
  ami = "ami-047a51fa27710816e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.SN-public-1.id
  availability_zone = "us-east-1a"
  security_groups = [aws_security_group.permit-web.id]
  key_name = "kris_desktop"
  tags = { Name = "VM-01"}
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    cd /var/www/html
    echo "VM $(hostname -f)" \
    > index.html
    systemctl restart httpd
    systemctl enable httpd
    EOF
}