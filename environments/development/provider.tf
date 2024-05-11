terraform {
  required_version = "1.7.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19.0"
    }
  }

#   Optional configuration to store state in S3. Need something to create bucket first though
  # backend "s3" {
  #   region = "us-east-1"
  #   key    = "dev/terraform.tfstate"
  #   bucket = "terraform-state-bucket-2343256"
  # }
}

provider "aws" {
  region = var.aws_region
  # allowed_account_ids = ["1234567890"] (possible way to ensure deployments are only done on a specific account)
}
