resource "aws_iam_openid_connect_provider" "oidcp" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_certificate.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
  depends_on = [
    module.dev_eks_cluster
  ]
  lifecycle {
    ignore_changes = [
      url
    ]
  }
}

resource "aws_iam_role" "oidc_role" {
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
  name               = "${var.cluster_name}-oidc-role"
}

resource "aws_eks_identity_provider_config" "idp_config" {
  cluster_name = var.cluster_name
  oidc {
    client_id                     = substr(data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer, -32, -1)
    identity_provider_config_name = "${var.cluster_name}config"
    issuer_url                    = "https://${aws_iam_openid_connect_provider.oidcp.url}"
  }
  depends_on = [
    module.dev_eks_cluster
  ]
  lifecycle {
    ignore_changes = [
      oidc[0].client_id,
      oidc[0].identity_provider_config_name,
      oidc[0].issuer_url
    ]
  }
}