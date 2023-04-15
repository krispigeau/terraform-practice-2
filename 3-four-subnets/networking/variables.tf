# varaibles used by networking module

variable "vpc_cidr" {
  type = string
}

variable "counter" {
  type = number
}

variable "public_cidrs" {
  type = list(any)
}

variable "private_cidrs" {
  type = list(any)
}
