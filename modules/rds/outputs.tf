# Output the RDS instance endpoint
output "rds_endpoint" {
  description = "The endpoint of the RDS PostgreSQL instance."
  value       = aws_db_instance.rds_instance.endpoint
}

# Output the RDS instance identifier
output "rds_instance_identifier" {
  description = "The identifier of the RDS PostgreSQL instance."
  value       = aws_db_instance.rds_instance.id
}

output "rds_password" {
  description = "The identifier of the RDS PostgreSQL instance."
  value       = aws_db_instance.rds_instance.id
}

# Output the RDS instance username
output "rds_username" {
  description = "The username for the RDS PostgreSQL instance."
  value       = aws_db_instance.rds_instance.username
}
