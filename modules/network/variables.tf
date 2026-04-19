variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for subnets"
  type        = list(string)
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the instance"
  type        = list(string)
}

variable "allowed_http_cidrs" {
  description = "List of CIDR blocks allowed to access HTTP (port 80)"
  type        = list(string)
}

variable "allowed_https_cidrs" {
  description = "List of CIDR blocks allowed to access HTTPS (port 443)"
  type        = list(string)
}