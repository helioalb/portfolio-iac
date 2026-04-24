variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type        = string
}

variable "enable_docker" {
  description = "Whether to install Docker on the EC2 instance"
  type        = bool
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. If empty, the latest Amazon Linux 2023 AMI will be used"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
}

variable "subnet_public_ids" {
  description = "Subnet public ids available"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups"
  type        = set(string)
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access. Leave empty to disable SSH key access"
  type        = string
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
}

variable "root_volume_type" {
  description = "Type of the root EBS volume"
  type        = string
}