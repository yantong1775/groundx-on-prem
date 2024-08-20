module "network" {
  source = "../../../modules/network"
  environment = var.environment

  network_cidr          = "10.0.0.0/16"
  subnet_cidrs          = ["10.0.1.0/24", "10.0.2.0/24"]
  security_rules        = {
    ingress_rule = {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  create_security_groups = var.create_security_groups
  create_subnets         = var.create_subnets
  security_group_ids     = local.use_existing_security_groups ? var.security_group_ids : []
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

resource "aws_security_group" "eyelevel" {
  count = var.create_security_groups ? 1 : 0
  vpc_id = var.create_vpc ? aws_vpc.eyelevel[0].id : null

  dynamic "ingress" {
    for_each = var.create_security_groups ? module.network.security_rules : {}
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  tags = {
    Name = "eyelevel-sg-${var.environment}"
  }
}

output "security_group_ids" {
  value = var.create_security_groups ? [for sg in aws_security_group.eyelevel : sg.id] : module.network.security_group_ids
}

output "subnet_ids" {
  value = var.create_subnets ? aws_subnet.eyelevel[*].id : module.network.subnet_ids
}