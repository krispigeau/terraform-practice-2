# Variables for compute

variable "ec_ami" {
  decription = "AWs image id for us-east-1"
  type       = string
}

variable "networking_var_public_subnet" {
  description = "public subnet id passed from networking module"
  type        = string
}

