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

resource "kubectl_manifest" "aws_auth" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/managed-by: Terraform
  name: aws-auth
  namespace: kube-system
data:
  mapAccounts: |
    []
  mapRoles: |
${indent(4, yamlencode(local.aws_auth_roles))}
  mapUsers: |
    []
YAML

  depends_on = [
    module.karpenter
  ]
}
