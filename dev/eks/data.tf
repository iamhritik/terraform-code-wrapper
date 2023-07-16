################################################################################
#eks-cluster related data block
################################################################################
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "devterraform-tfstate"
    key    = "dev/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}

################################################################################
#karpenter related data block
################################################################################
data "aws_availability_zones" "available" {}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

data "aws_vpc" "details" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}
################################################################################
#OIDC related data block
################################################################################
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  depends_on = [
    module.dev_eks_cluster
  ]
}

data "tls_certificate" "cluster_certificate" {
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
  depends_on = [
    module.dev_eks_cluster
  ]
}

data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.oidcp.url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidcp.arn]
      type        = "Federated"
    }
  }
}