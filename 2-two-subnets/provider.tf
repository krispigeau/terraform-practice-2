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
  region                   = "us-east-1"
  shared_credentials_files = ["/home/kris/.aws/credentials"]
}