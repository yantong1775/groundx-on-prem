# GLOBALS

variable "create_all" {
  description = "Create all services"
  type        = bool
  default     = true
}

variable "create_kafka" {
  description = "Create Kafka service"
  type        = bool
  default     = true
}

variable "create_mysql" {
  description = "Create MySQL service"
  type        = bool
  default     = true
}

variable "create_redis" {
  description = "Create Redis service"
  type        = bool
  default     = true
}

variable "kube_config_path" {
  description = "Path to Kubernetes cluster config file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Namespace for cluster"
  type        = string
  default     = "eyelevel"
}

variable "pv_class" {
  description = "Storage class for the PersistentVolume and PersistentVolumeClaim"
  type        = string
  default     = "local-storage"
}


# CACHE

variable "cache_image_pull" {
  description = "Pull policy for container image"
  type        = string
  default     = "IfNotPresent"
}

variable "cache_image_tag" {
  description = "Tag for container image"
  type        = string
  default     = "latest"
}

variable "cache_image_url" {
  description = "Address for container image"
  type        = string
  default     = "public.ecr.aws/c9r4x6y5/eyelevel/redis"
}

variable "cache_ip_type" {
  description = "Type of IP address"
  type        = string
  default     = "ClusterIP"
}

variable "cache_mount_path" {
  description = "Container path where redis data will mount"
  type        = string
  default     = "/mnt/redis"
}

variable "cache_node" {
  description = "Node where the PersistentVolume will be available"
  type        = string
  default     = "crc"
}

variable "cache_port" {
  description = "Local port for access"
  type        = number
  default     = 6379
}

variable "cache_service" {
  description = "Name for service"
  type        = string
  default     = "redis"
}

variable "cache_version" {
  description = "Redis version"
  type        = string
  default     = "6.1"
}


# LOCAL CACHE

variable "cache_pv_access" {
  description = "Access modes for the PersistentVolume and PersistentVolumeClaim"
  type        = string
  default     = "ReadWriteMany"
}

variable "cache_pv_path" {
  description = "Local path for the PersistentVolume"
  type        = string
}

variable "cache_pv_size" {
  description = "Size of the PersistentVolume and PersistentVolumeClaim"
  type        = string
  default     = "1Gi"
}

variable "cache_replicas" {
  description = "Number of initial database replicas"
  type        = number
  default     = 1
}


# DATABASE

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


# LOCAL DATABASE

variable "db_pv_access" {
  description = "Access modes for the PersistentVolume and PersistentVolumeClaim"
  type        = string
  default     = "ReadWriteMany"
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


# STREAM

variable "stream_chart" {
  description = "Helm chart for Kafka operator"
  type        = string
  default     = "oci://quay.io/strimzi-helm/strimzi-kafka-operator"
}

variable "stream_chart_version" {
  description = "Helm chart version for Kafka operator"
  type        = string
  default     = "0.35.0"
}

variable "stream_cpu_limits" {
  description = "CPU allocated to limits"
  type        = string
  default     = "200m"
}

variable "stream_cpu_requests" {
  description = "CPU allocated to requests"
  type        = string
  default     = "100m"
}

variable "stream_memory_limits" {
  description = "Memory allocated to limits"
  type        = string
  default     = "512Mi"
}

variable "stream_memory_requests" {
  description = "Memory allocated to requests"
  type        = string
  default     = "256Mi"
}

variable "stream_port" {
  description = "Local port for access"
  type        = number
  default     = 9092
}

variable "stream_replicas_operator" {
  description = "Number of initial operator replicas"
  type        = number
  default     = 3
}

variable "stream_replicas_service" {
  description = "Number of initial service replicas"
  type        = number
  default     = 3
}

variable "stream_replicas_zookeeper" {
  description = "Number of initial zookeeper replicas"
  type        = number
  default     = 3
}

variable "stream_service" {
  description = "Name for service"
  type        = string
  default     = "kafka"
}

variable "stream_storage_service" {
  description = "Storage memory allocated to service"
  type        = string
  default     = "2Gi"
}

variable "stream_storage_zookeeper" {
  description = "Storage memory allocated to zookeeper"
  type        = string
  default     = "1Gi"
}

variable "stream_version" {
  description = "Kafka version"
  type        = string
  default     = "3.4.0"
}