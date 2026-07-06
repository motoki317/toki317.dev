locals {
  region      = "ap-northeast-1"
  repository  = "motoki317/toki317.dev"
  main_branch = "main"

  # The backend "s3" block below can't reference these locals; keep them in sync.
  tfstate_bucket = "toki317-aws-tfstate"
  tfstate_key    = "aws/terraform.tfstate"
}

terraform {
  required_version = ">= 1.10" # native S3 state locking (use_lockfile)

  backend "s3" {
    bucket       = "toki317-aws-tfstate"
    key          = "aws/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Repo      = local.repository
    }
  }
}
