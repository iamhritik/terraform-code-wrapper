locals {
  common_tags        = { ENV : "DEV", OWNER : "DEVOPS", PROJECT : "DEV_EKS_CLUSTER", COMPONENT : "EKS" }
  worker_group1_tags = { "karpenter.sh/discovery" : var.cluster_name }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "devterraform-tfstate"
    key    = "dev/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}
module "dev_eks_cluster" {
  source                    = "OT-CLOUD-KIT/eks/aws"
  version                   = "1.1.0"
  cluster_name              = var.cluster_name
  eks_cluster_version       = var.cluster_version
  enabled_cluster_log_types = ["api", "audit"]
  subnets                   = flatten(data.terraform_remote_state.vpc.outputs.private_subnets_id)
  tags                      = local.common_tags
  kubeconfig_name           = "dev_config"
  config_output_path        = "config"
  eks_node_group_name       = "dev_node_group"
  region                    = var.region
  create_node_group         = true
  endpoint_private          = true
  endpoint_public           = false
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  node_groups = {
    "nodegroup_01" = {
      subnets            = flatten(data.terraform_remote_state.vpc.outputs.private_subnets_id)
      ssh_key            = "opstree"
      security_group_ids = ["sg-001d4d01d818ed07f"]
      instance_type      = ["t3a.small"]
      desired_capacity   = 2
      max_capacity       = 2
      min_capacity       = 2
      disk_size          = 10
      capacity_type      = "ON_DEMAND"
      tags               = merge(local.common_tags, local.worker_group1_tags)
      labels             = { "node_group" : var.nodegroup_name }
    }
  }
}