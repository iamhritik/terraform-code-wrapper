locals {
  common_tags        = { ENV : "DEV", OWNER : "DEVOPS", PROJECT : "DEV_EKS_CLUSTER", COMPONENT : "EKS" }
  worker_group1_tags = { "name" : "nodegroup-01" }
}

module "dev_eks_cluster" {
  source                    = "OT-CLOUD-KIT/eks/aws"
  version                   = "1.1.0"
  cluster_name              = "dev-cluster"
  eks_cluster_version       = "1.24"
  enabled_cluster_log_types = ["api", "audit"]
  subnets                   = ["subnet-00ee81ae8342dafd0", "subnet-0bf81719cc087912d"]
  tags                      = local.common_tags
  kubeconfig_name           = "dev_config"
  config_output_path        = "config"
  eks_node_group_name       = "dev_node_group"
  region                    = "ap-south-1"
  create_node_group         = true
  endpoint_private          = true
  endpoint_public           = false
  vpc_id                    = "vpc-0206ed6a00eb45e52"
  node_groups = {
    "worker1" = {
      subnets            = ["subnet-00ee81ae8342dafd0", "subnet-0bf81719cc087912d"]
      ssh_key            = "opstree"
      security_group_ids = ["sg-09a50445f53421d1e"]
      instance_type      = ["t3a.small"]
      desired_capacity   = 1
      max_capacity       = 2
      min_capacity       = 1
      disk_size          = 10
      capacity_type      = "ON_DEMAND"
      tags               = merge(local.common_tags, local.worker_group1_tags)
      labels             = { "node_group" : "nodegroup_01" }
    }
  }
}

#add one output to print eks cluster security group id as well

#To fetch controlplane security group id
data "aws_security_group" "controlplane_sg" {
  tags = {
    "aws:eks:cluster-name" = "dev-cluster"
  }
  depends_on = [
    module.dev_eks_cluster
  ]
}

#Jenkins SG to communicate with eks cluster
resource "aws_security_group_rule" "example" {
  security_group_id        = data.aws_security_group.controlplane_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "sg-00ca991b504ae1fdc" #specify SG ID that you used to connect with kubernetes API server
  depends_on = [
    data.aws_security_group.controlplane_sg
  ]
}