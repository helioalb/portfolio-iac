terraform {
  required_version = ">= 1.6.0"

  cloud {
    organization = "portfolio-helioalb"

    workspaces {
      name = "portfolio-iac"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.33.0"
    }
  }
}
