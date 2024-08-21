locals {
  subnet_ids         = var.create_subnets ? ["subnet-placeholder"] : var.subnet_ids
}