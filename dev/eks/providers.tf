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

provider "aws" {
  region = "ap-south-1"
}


provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}