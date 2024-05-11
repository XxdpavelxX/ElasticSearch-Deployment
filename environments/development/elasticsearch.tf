module "elasticsearch_resources" {
  source               = "../../module"
  stage_name           = var.stage_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  instance_sg_ssh_cidr = var.instance_sg_ssh_cidr
  instance_sg_tcp_cidr = var.instance_sg_tcp_cidr
  instance_type        = var.instance_type
  instance_name        = var.instance_name
}

output "elasticsearch_url" {
  value = module.elasticsearch_resources.elasticsearch_url
}
