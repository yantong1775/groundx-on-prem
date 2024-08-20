provider "aws" {
  region = var.region
}

locals {
  use_existing_security_groups = var.create_security_groups ? false : true
  use_existing_subnets = var.create_vpc ? false : !var.create_subnets
  vpc_id = var.create_vpc ? aws_vpc.eyelevel[0].id : var.vpc_id
}