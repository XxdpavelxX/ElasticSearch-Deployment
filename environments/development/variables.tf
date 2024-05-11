variable "aws_region" {
  type        = string
  description = "Name of the AWS region to deploy AWS resources"
}

# Stage Variables
variable "stage_name" {
  type        = string
  description = "Name of the stage"
}

# EC2 Variables
variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "instance_name" {
  type        = string
  description = "Name of the EC2 instance"
}

variable "instance_sg_ssh_cidr" {
  type        = string
  description = "CIDR block for SSH access to the EC2 instance"
}

variable "instance_sg_tcp_cidr" {
  type        = string
  description = "CIDR block for TCP access to the EC2 instance"
}

# Vpc variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the ES VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the ES Public Subnet"
}
