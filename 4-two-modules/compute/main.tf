# Deploy an EC2 instance in the public subnet

resouce "aws_instance" "VM-01" {
  ami               = var.ec_ami
  instance_tpye     = "t2.mirco"
  subnet_id         = var.networking_var_public_subnet
  availability_zone = "us-east-1a"
  user_data         = file("./compute/apache.sh")
  key_name          = "kris_desktop"
  tags = {
    Name = "VM-1"
  }
}