terraform {
  cloud {
    organization = "tiger_projects"
    workspaces {
      name = "data-processing-with-lambda"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1" # Frankfurt
}

module "s3" {
  source         = "./modules/s3"
  s3_bucket_name = var.s3_bucket_name
}

module "lambda_function" {
  source = "./modules/lambda"

  bucket_name      = var.s3_bucket_name
  function_name    = var.lambda_function_name
  lambda_role_name = var.lambda_role_name
  bucket_id        = module.s3.s3_bucket_id
}
