#GLOBALS

variable "kube_config_path" {
  description = "Path to Kubernetes cluster config file"
  type        = string
  default     = "~/.kube/config"
}


#DATABASE

variable "db_image_pull" {
  description = "Pull policy for container image"
  type        = string
  default     = "IfNotPresent"
}

variable "db_image_tag" {
  description = "Tag for container image"
  type        = string
  default     = "latest"
}

variable "db_image_url" {
  description = "Address for container image"
  type        = string
  default     = "public.ecr.aws/c9r4x6y5/eyelevel/mysql"
}

variable "db_ip_type" {
  description = "Type of IP address"
  type        = string
  default     = "ClusterIP"
}

variable "db_mount_path" {
  description = "Container path where mysql data will mount"
  type        = string
  default     = "/var/lib/mysql"
}

variable "db_name" {
  description = "MySQL database name"
  type        = string
}

variable "db_namespace" {
  description = "Namespace for service"
  type        = string
  default     = "eyelevel"
}

variable "db_node" {
  description = "Node where the PersistentVolume will be available"
  type        = string
  default     = "crc"
}

variable "db_password" {
  description = "MySQL user password"
  type        = string
}

variable "db_port" {
  description = "Local port for access"
  type        = number
  default     = 3306
}

variable "db_root_password" {
  description = "MySQL root password"
  type        = string
}

variable "db_service" {
  description = "Name for service"
  type        = string
  default     = "mysql"
}

variable "db_username" {
  description = "MySQL user username"
  type        = string
}

variable "db_version" {
  description = "MySQL version"
  type        = string
  default     = "8.0"
}


# LOCAL

variable "db_pv_access" {
  description = "Access modes for the PersistentVolume and PersistentVolumeClaim"
  type        = string
  default     = "ReadWriteMany"
}

variable "db_pv_class" {
  description = "Storage class for the PersistentVolume and PersistentVolumeClaim"
  type        = string
  default     = "local-storage"
}

variable "db_pv_path" {
  description = "Local path for the PersistentVolume"
  type        = string
}

variable "db_pv_size" {
  description = "Size of the PersistentVolume and PersistentVolumeClaim"
  type        = string
  default     = "1Gi"
}

variable "db_replicas" {
  description = "Number of initial database replicas"
  type        = number
  default     = 1
}