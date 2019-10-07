locals {
  tags        = {
    "owner"            = "${var.owner}"
  }
}

module "vpc" {
  source                 = "../terraform/terraform/terraform-modules/vpc"
  name                   = var.owner
  cidr                   = "10.0.0.0/16"
  azs                    = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets        = ["10.0.0.0/24", "10.0.64.0/24", "10.0.128.0/24"]
  public_subnets         = ["10.0.32.0/24", "10.0.96.0/24", "10.0.160.0/24"]
  single_nat_gateway     = false
  enable_s3_endpoint     = true
  tags = local.tags

  public_subnet_tags = {
    "network" = "public"
  }

  private_subnet_tags = {
    "network" = "private"
  }
}
