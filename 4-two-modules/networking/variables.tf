# variables for networking module

variable "vpc_name" {
  description = "name of the VPC"
  type        = string
}

variable "address_space" {
  description = "IPv4 range of the VPC"
}

variable "azs" {
  description = "availability_zone"
  type        = string
}

output "output_sg" {
  value = aws_security_group.letweb
}

output "public_subnet_id" {
  value = aws_subnet.public-subnet.id
}