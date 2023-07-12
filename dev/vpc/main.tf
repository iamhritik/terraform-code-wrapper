module "vpc_creation" {
  source               = "OT-CLOUD-KIT/vpc/aws"
  version              = "1.0.1"
  cidr_block           = "10.0.0.0/16"
  vpc_name             = "dev-vpc"
  enable_dns_hostnames = true
  enable_vpc_logs      = false
  public_subnets_cidr  = ["10.0.0.0/18", "10.0.64.0/18"]
  private_subnets_cidr = ["10.0.128.0/18", "10.0.192.0/18"]
  avaialability_zones  = ["ap-south-1a", "ap-south-1b"]
  igw_name                                             = "dev-igw"
  pub_rt_name                                          = "dev-pub-rt"
  pub_subnet_name                                      = "dev-pub-subnet"
  pvt_rt_ame                                           = "dev-pvt-rt"
  pvt_subnet_name                                      = "dev-pvt-subnet"
  nat_name                                             = "demo-nat-gw"
  enable_igw_publicRouteTable_PublicSubnets_resource   = true
  enable_nat_privateRouteTable_PrivateSubnets_resource = true
  enable_public_web_security_group_resource            = false
  enable_pub_alb_resource                              = false
  enable_aws_route53_zone_resource                     = false
  tags                                                 = { "environment" : "dev", "provisioned_by" : "terraform" }
  #not required but still need it
  pvt_zone_name       = null
  logs_bucket         = null
  logs_bucket_arn     = null
  public_web_sg_name  = null
  alb_name            = null
  alb_certificate_arn = null
}