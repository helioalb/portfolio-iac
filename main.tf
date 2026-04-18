module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  project_name        = var.project_name
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}
################################################################################
# Data Sources
################################################################################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  name_prefix = "${var.project_name}-ec2-"
  description = "Security group for ${var.project_name} EC2 instance"
  vpc_id      = module.network.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "all_traffic" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.allowed_http_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "Allow HTTP from ${each.value}"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = toset(var.allowed_https_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "Allow HTTPS from ${each.value}"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.allowed_ssh_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "Allow SSH from ${each.value}"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

################################################################################
# User Data Script
################################################################################

locals {
  user_data = var.enable_docker ? base64encode(templatefile("${path.module}/user_data.sh", {})) : null
}

resource "aws_instance" "this" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = module.network.subnet_public_id
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  associate_public_ip_address = var.associate_public_ip

  user_data_base64 = local.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2
  }

  monitoring = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
