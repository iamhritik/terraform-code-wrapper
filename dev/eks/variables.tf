variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "VPC Subnets ID"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  default     = null
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  default     = null
  type        = string
}

variable "cluster_log_types" {
  description = "EKS Cluster Log Types - [api,audit,authenticator,controllerManager,scheduler]"
  type        = list(string)
}

variable "kubeconfig_path" {
  description = "EKS Cluster kubeconfig file path"
  type        = string
  default     = "kubeconfig"
}

variable "endpoint_private" {
  description = "EKS Cluster private endpoint"
  type = bool
  default = true
}

variable "endpoint_public" {
  description = "EKS Cluster public endpoint"
  type = bool
  default = false
}

variable "nodegroup_role_name" {
  description = "EKS Cluster Nodegroup role name"
  default     = null
  type        = string
}

variable "nodegroup_instane_type" {
  type        = list(any)
  default     = ["t3a.small"]
  description = "EKS nodegroup instance_types"
}

variable "nodegroup_desired_size" {
  type        = number
  default     = 2
  description = "EKS nodegroup desired size"
}

variable "nodegroup_max_size" {
  type        = number
  default     = 3
  description = "EKS nodegroup max size"
}

variable "nodegroup_min_size" {
  type        = number
  default     = 2
  description = "EKS nodegroup min size"
}

variable "nodegroup_labels" {
  description = "EKS Nodegroup labels"
  type        = map(string)
}

variable "karpenter_version" {
  description = "karpenter version"
  default     = "v0.29.0"
  type        = string
}
variable "karpenter_instance_category" {
  description = "karpenter instance category"
  default     = ["t"]
  type        = list(string)
}

variable "karpenter_capacity_type" {
  description = "karpenter capacity type"
  default     = ["spot"]
  type        = list(string)
}

variable "provisioner_cpu_limit" {
  description = "karpenter provisioner cpu limit"
  default     = "5"
  type        = string
}