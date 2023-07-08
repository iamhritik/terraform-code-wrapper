terraform {
  required_version = "~> 1.5.0"
  required_providers {
    aws = {
      version = "~> 5.0"
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