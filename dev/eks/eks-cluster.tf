module "dev_eks_cluster" {
  source                    = "OT-CLOUD-KIT/eks/aws"
  version                   = "1.1.0"
  cluster_name              = var.cluster_name
  eks_cluster_version       = var.cluster_version
  enabled_cluster_log_types = var.cluster_log_types
  subnets                   = var.subnet_ids
  tags                      = local.common_tags
  kubeconfig_name           = null #not used anywhere in module but still need to define it
  config_output_path        = var.kubeconfig_path
  eks_node_group_name       = var.nodegroup_role_name
  region                    = var.region
  create_node_group         = true
  endpoint_private          = var.endpoint_private
  endpoint_public           = var.endpoint_public
  vpc_id                    = var.vpc_id
  node_groups = {
    "nodegroup_01" = {
      subnets            = var.subnet_ids
      ssh_key            = "opstree"
      security_group_ids = [var.cluster_access_sg]
      instance_type      = var.nodegroup_instane_type
      desired_capacity   = var.nodegroup_desired_size
      max_capacity       = var.nodegroup_max_size
      min_capacity       = var.nodegroup_min_size
      disk_size          = var.disk_size
      capacity_type      = var.capacity_type
      tags               = merge(local.common_tags, local.node_group_01_tags)
      labels             = var.nodegroup_labels
    }
  }

  depends_on = [ 
    data.terraform_remote_state.vpc
  ]
}