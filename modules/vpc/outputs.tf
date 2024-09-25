output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The public subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "The private subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

output "internet_gateway_id" {
  description = "The Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "The NAT Gateway ID"
  value       = aws_nat_gateway.nat.id
}

output "nat_gateway_eip" {
  value = aws_eip.nat_gateway_eip.public_ip
}
