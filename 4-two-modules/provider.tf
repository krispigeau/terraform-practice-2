# Provider definition for AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region                  = "us-east-1"
  chared_credentials_file = "/home/ec2-user/.terraform.d/credentials.tfrc.json"
}

