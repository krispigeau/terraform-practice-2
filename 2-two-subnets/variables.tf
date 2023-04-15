# Define Variables

variable "usregion" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr_block" {
  description = "vpc IP address space"
  type        = string
}

variable "subnet_prefix" {
  description = "subnet prefixes"
  type        = list(any)
}

variable "azone" {
  description = "availability zones"
  type        = list(any)
}

variable "ami-id" {
  description = "id of AWS AMI"
  type        = string
}