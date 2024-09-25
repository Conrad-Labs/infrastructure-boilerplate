output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "dns_name" {
  value = aws_lb.ALB.dns_name
}

output "zone_id" {
  value = aws_lb.ALB.zone_id
}