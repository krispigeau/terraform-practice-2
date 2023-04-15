# This main inherits

module "platform" {
  source = "../../../modules/services/platform"
  # Variables are defined or declared in the root module.
  # These are the specific values for this environment.
  vpc_name     = "example"
  cidr_block   = "10.0.0.0/16"
  igw_name     = "igw"
  public_cidr  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_cidr = ["10.0.2.0/24", "10.0.4.0/24"]
  az_pub       = ["us-east-1a", "us-east-1c"]
  az_priv      = ["us-east-1b", "us-east-1d"]
  ami          = "ami-04902260ca3d33422"
  ec2_type     = "t2.micro"
  key          = "kris_desktop"
  ec2_name     = "VM"
}