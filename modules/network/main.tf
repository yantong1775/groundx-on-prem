locals {
  security_group_ids = var.create_security_groups ? ["sg-placeholder"] : var.security_group_ids
  subnet_ids         = var.create_subnets ? ["subnet-placeholder"] : var.subnet_ids
}