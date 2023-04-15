# main.tf at root level. root/main.tf
# defines the modules being used
# defines values for variables used by the modules
# the module contain references to these variable values

module "networking" {
  source        = "./networking"
  vpc_cidr      = "192.168.0.0/16"
  public_cidrs  = ["192.168.1.0/24", "192.168.3.0/24"]
  private_cidrs = ["192.168.2.0/24", "192.168.4.0/24"]
  counter       = 2
}