variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}