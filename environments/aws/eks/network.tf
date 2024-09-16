module "network" {
  source = "../../../modules/network"
  environment = var.environment

  ingress_cidr           = var.ingress_cidr
  network_cidr           = "10.0.0.0/16"
  subnet_cidrs           = ["10.0.1.0/24", "10.0.2.0/24"]

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
  vpc_id     = local.use_existing_vpc ? var.vpc_id : aws_vpc.eyelevel[0].id
  cidr_block = element(module.network.subnet_cidrs, count.index)

  tags = {
    Name = "eyelevel-subnet-${count.index}-${var.environment}"
  }
}

resource "aws_route_table" "eyelevel" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.eyelevel[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eyelevel[0].id
  }

  tags = {
    Name = "eyelevel-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "eyelevel" {
  count          = length(aws_subnet.eyelevel[*].id)
  subnet_id      = aws_subnet.eyelevel[count.index].id
  route_table_id = aws_route_table.eyelevel[0].id
}

resource "aws_internet_gateway" "eyelevel" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.eyelevel[0].id

  tags = {
    Name = "eyelevel-igw-${var.environment}"
  }
}

resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "EKS Node security group"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [module.network.ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "subnet_ids" {
  value = var.create_subnets ? aws_subnet.eyelevel[*].id : module.network.subnet_ids
}

output "vpc_id" {
  value = var.create_vpc ? aws_vpc.eyelevel[0].id : local.vpc_id
}

output "eks_node_sg_id" {
  value = aws_security_group.eks_node_sg.id
}