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

locals {
  user_data = var.enable_docker ? base64encode(templatefile("${path.module}/user_data.sh", {})) : null
}

resource "aws_instance" "public" {
  count                  = var.instance_count
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_public_ids[count.index % length(var.subnet_public_ids)]
  vpc_security_group_ids = var.security_groups
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
