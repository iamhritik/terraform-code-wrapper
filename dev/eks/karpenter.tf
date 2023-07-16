module "karpenter" {
  source                 = "../../modules/karpenter"
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
  version             = var.karpenter_version

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

  # set{
  #   name = "controller.resources.requests.cpu"
  #   value = "0.1"
  # }

  # set{
  #   name = "controller.resources.requests.memory"
  #   value = "100"
  # }

  # set{
  #   name = "controller.resources.limits.cpu"
  #   value = "0.5"
  # }

  # set{
  #   name = "controller.resources.limits.memory"
  #   value = "200"
  # }
  depends_on = [
    module.dev_eks_cluster,
    module.karpenter,
    aws_security_group_rule.cluster_access
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
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ${var.karpenter_instance_category}
        - key: karpenter.sh/capacity-type
          operator: In
          values: ${var.karpenter_capacity_type}
      limits:
        resources:
          cpu: ${var.provisioner_cpu_limit}
      providerRef:
        name: default
      ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter,
    aws_security_group_rule.cluster_access
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
    helm_release.karpenter,
    aws_security_group_rule.cluster_access
  ]
}

################################################################################
#karpenter tagging
################################################################################
resource "aws_ec2_tag" "karpenter_subnet_tags" {
  for_each    = var.subnet_ids
  resource_id = each.key
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

resource "aws_ec2_tag" "karpenter_sg_tags_01" {
  resource_id = data.aws_security_group.controlplane_sg.id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
  depends_on = [
    module.dev_eks_cluster,
    data.aws_security_group.controlplane_sg
  ]
}

resource "aws_ec2_tag" "karpenter_sg_tags_02" {
  resource_id = module.dev_eks_cluster.module_node_group_resources["dev-cluster:nodegroup_01"][0].remote_access_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
  depends_on = [
    module.dev_eks_cluster,
    data.aws_security_group.controlplane_sg
  ]
}