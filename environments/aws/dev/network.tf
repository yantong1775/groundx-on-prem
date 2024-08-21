module "network" {
  source = "../../../modules/network"
  environment = var.environment

  network_cidr          = "10.0.0.0/16"
  subnet_cidrs          = ["10.0.1.0/24", "10.0.2.0/24"]

  create_subnets         = var.create_subnets
  subnet_ids             = local.use_existing_subnets ? var.subnet_ids : []
  vpc_id                 = local.vpc_id
}

resource "aws_vpc" "eyelevel" {
  count      = var.create_vpc ? 1 : 0
  cidr_block = module.network.network_cidr

  tags = {
    Name = "eyelevel-vpc-${var.environment}"
  }
}

resource "aws_subnet" "eyelevel" {
  count      = local.use_existing_subnets ? 0 : length(module.network.subnet_cidrs)
  vpc_id     = var.create_vpc ? aws_vpc.eyelevel[0].id : local.vpc_id
  cidr_block = element(module.network.subnet_cidrs, count.index)

  tags = {
    Name = "eyelevel-subnet-${count.index}-${var.environment}"
  }
}

output "subnet_ids" {
  value = var.create_subnets ? aws_subnet.eyelevel[*].id : module.network.subnet_ids
}

output "vpc_id" {
  value = var.create_vpc ?aws_vpc.eyelevel[0].id : local.vpc_id
}
