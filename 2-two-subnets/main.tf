# root/main.terraform

module "networking" {
  source = "./networking"
  vpc_cidr = "192.168.0.0/16"
  counter = 2
  public_cidr = ["192.168.1.0/24"]
  private_cidr = ["192.168.2.0/24"]
}