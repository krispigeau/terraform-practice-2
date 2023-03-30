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
resource "aws_instance" "VM-08" {
  ami               = "ami-00c39f71452c08778"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "kris_desktop"
  security_groups   = ["demo-sg"]
  tags              = { Name = "VM-08" }
  user_data         = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    cd /var/www/html
    echo "Hello from $(hostname -f)" \
    > index.html
    systemctl restart httpd
    systemctl enable httpd
    EOF
}