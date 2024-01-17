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
