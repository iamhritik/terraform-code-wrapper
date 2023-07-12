output "vpc_id" {
  value = module.vpc_creation.vpc_id
}

output "private_subnets_id" {
  value = module.vpc_creation.pvt_subnet_ids
}

output "public_subnets_id" {
  value = module.vpc_creation.public_subnet_ids
}