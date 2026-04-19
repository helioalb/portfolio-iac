output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_public_ids" {
  value = aws_subnet.publics[*].id
}

output "subnet_private_ids" {
  value = aws_subnet.privates[*].id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}