# Stage Variables
stage_name = "prod"

# EC2 variables
instance_type        = "t2.large"
instance_name        = "ElasticSearch"
instance_sg_ssh_cidr = "0.0.0.0/0"
instance_sg_tcp_cidr = "0.0.0.0/0"

# VPC variables
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
