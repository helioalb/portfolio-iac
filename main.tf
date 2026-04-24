module "network" {
  source              = "./modules/network"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  subnet_cidr_blocks  = var.subnet_cidr_blocks
  allowed_http_cidrs  = var.allowed_http_cidrs
  allowed_https_cidrs = var.allowed_https_cidrs
  allowed_ssh_cidrs   = var.allowed_ssh_cidrs
}

module "cluster" {
  source              = "./modules/cluster"
  project_name        = var.project_name
  enable_docker       = var.enable_docker
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  instance_count      = var.instance_count
  subnet_public_ids   = module.network.subnet_public_ids
  security_groups     = [module.network.ec2_security_group_id]
  key_pair_name       = var.key_pair_name
  associate_public_ip = var.associate_public_ip
  root_volume_size    = var.root_volume_size
  root_volume_type    = var.root_volume_type
}