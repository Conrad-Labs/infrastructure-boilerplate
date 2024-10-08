output "route53_zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "record_fqdn" {
  description = "The FQDNs of the Route 53 records."
  value       = [for record in aws_route53_record.this : record.fqdn]
}
