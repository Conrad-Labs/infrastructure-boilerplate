output "route53_zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "record_fqdn" {
  description = "The FQDN of the DNS record."
  value       = aws_route53_record.this.fqdn
}
