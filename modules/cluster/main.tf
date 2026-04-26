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
  key_name  = var.key_pair_name != "" ? var.key_pair_name : null
  image_id  = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
}

resource "aws_launch_template" "template" {
  name          = "${var.project_name}-template"
  image_id      = local.image_id
  instance_type = var.instance_type
  key_name      = local.key_name

  user_data = local.user_data

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_groups
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-ec2"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.template.id
    version = "$latest"
  }
}
