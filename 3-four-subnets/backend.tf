# Backend for Terraform Cloud
terraform {
  cloud {
    organization = "KrisCo"

    workspaces {
      name = "project1"
    }
  }

  required_version = ">= 1.1.2"
}
