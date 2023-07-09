data "aws_availability_zones" "available" {}
data "aws_ecrpublic_authorization_token" "token" {
    provider = aws.virginia
}
data "aws_vpc" "details" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}
locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = var.cluster_version
  region          = var.region
  vpc_cidr = data.aws_vpc.details.cidr_block
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    resource = "karpenter"
  }
}

################################################################################
# Karpenter
################################################################################
module "karpenter" {
  source = "../../modules/karpenter"
  cluster_name           = var.cluster_name
  irsa_oidc_provider_arn = aws_iam_openid_connect_provider.oidcp.arn
  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  tags = local.tags
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "v0.21.1"

  set {
    name  = "settings.aws.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.dev_eks_cluster.endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }
  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }
  depends_on = [ 
    module.dev_eks_cluster,
    module.karpenter
   ]

}

resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: default
    spec:
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
      limits:
        resources:
          cpu: 2
      providerRef:
        name: default
      ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        karpenter.sh/discovery: ${var.cluster_name}
      securityGroupSelector:
        karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
  YAML
  depends_on = [
    helm_release.karpenter
  ]
}