#eks-cluster related local block
locals {
  common_tags        = { ENV : "DEV", OWNER : "DEVOPS", PROJECT : "DEV_EKS_CLUSTER", COMPONENT : "EKS" }
  node_group_01_tags = { "karpenter.sh/discovery" : var.cluster_name }
}


#aws-auth related local block
locals {
  aws_auth_roles = concat(
    [
      {
        rolearn  = module.dev_eks_cluster.node_iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = module.karpenter.role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ]
  )
}


#karpenter related local block
locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = var.cluster_version
  region          = var.region
  vpc_cidr        = data.aws_vpc.details.cidr_block
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    resource = "karpenter"
  }
}


