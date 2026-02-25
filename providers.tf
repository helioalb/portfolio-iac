provider "aws" {
  region = var.aws_region

  allowed_account_ids = ["427261938086"]

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
