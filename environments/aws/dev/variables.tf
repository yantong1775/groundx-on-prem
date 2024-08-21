# GLOBAL

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}


# VPC

variable "region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-east-2"
}

variable "vpc_id" {
  description = "The ID for an existing VPC"
  type        = string
  default     = null
}

# KUBERNETES

variable "cluster_id" {
  description = "The ID for an existing cluster"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "The EKS cluster name"
  type        = string
  default     = "eyelevel"
}

variable "cluster_version" {
  description = "The EKS cluster version"
  type        = string
  default     = "1.30"
}

variable "db_instance_type" {
  description = "The size of the base DB EKS instance"
  type        = string
  default     = "t3.micro"
}

# NETWORK

variable "create_subnets" {
  description = "Whether to create new subnets"
  type        = bool
  default     = false
}

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "The subnet IDs for resources"
  type        = list(string)
}

# DATABASE

variable "db_password" {
  description = "MySQL root password"
  type        = string
}

variable "db_name" {
  description = "MySQL database name"
  type        = string
}

variable "db_username" {
  description = "MySQL root username"
  type        = string
}