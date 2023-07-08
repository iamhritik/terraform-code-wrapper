variable "karpenter_version" {
  description = "karpenter version"
  default     = "v0.29.0"
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  default     = null
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  default     = null
  type        = string
}

variable "nodegroup_name" {
  description = "EKS Cluster Name"
  default     = null
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
  type        = string
}
