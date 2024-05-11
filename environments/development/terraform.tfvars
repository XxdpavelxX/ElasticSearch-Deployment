# Provider variables
aws_region = "us-east-1"

# Stage Variables
stage_name = "dev"

# EC2 variables
instance_type        = "t2.large"
instance_name        = "ElasticSearch"
instance_sg_ssh_cidr = "0.0.0.0/0"
instance_sg_tcp_cidr = "0.0.0.0/0"

# VPC variables
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.2.0/24"
