variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID for an existing VPC"
  type        = string
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of VPC security group IDs"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "network_cidr" {
  description = "The CIDR block for the network (VPC, VNet, etc.)"
  type        = string
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
}

variable "security_rules" {
  description = "A map of security rules for network access"
  type        = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "create_security_groups" {
  description = "Whether to create new security groups"
  type        = bool
  default     = false
}

variable "create_subnets" {
  description = "Whether to create new subnets"
  type        = bool
  default     = false
}

variable "create_vpc" {
  description = "Whether to create new VPC"
  type        = bool
  default     = false
}