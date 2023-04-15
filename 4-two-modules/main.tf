# root main file

module "networking" {
  source         = "./networking"
  aws_region     = "us-east-1"
  vpc_name       = "vpc-example"
  azs            = "us-east-1a"
  address_space  = "192.168.0.0/16"
  public_subnet  = "192.168.1.0/24"
  private_subnet = "192.168.2.0/24"
}

module "compute" {
  souce                        = "./comptue"
  ec_ami                       = "ami-0533f2ba8a1995cf9"
  networking_var_public_subnet = module.networking.public_subnet_id
}