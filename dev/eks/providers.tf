terraform {
  required_version = "~> 1.5.0"
  required_providers {
    aws = {
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
  backend "s3" {
    bucket = "devterraform-tfstate"
    key    = "dev/eks/terraform.tfstate"
    region = "ap-south-1"
  }
}
#karpenter providers
provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}


provider "kubernetes" {
  host                   = module.dev_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(module.dev_eks_cluster.kubeconfig-certificate-authority-data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.dev_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.dev_eks_cluster.kubeconfig-certificate-authority-data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.dev_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(module.dev_eks_cluster.kubeconfig-certificate-authority-data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}