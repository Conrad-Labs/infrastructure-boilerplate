terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

# Create RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  subnet_ids = var.subnet_ids

  tags = {
    Name = "RDS subnet group"
  }
}

# Generate random password for RDS instance
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-_=+<>?"
}

# # Store DB username in AWS SSM Parameter Store
# resource "aws_ssm_parameter" "rds_username" {
#   name  = "/rds/db_username"
#   type  = "String"
#   value = var.db_username

#   tags = {
#     Name = "RDS DB Username"
#   }
# }

# # Store generated DB username in AWS SSM Parameter Store
# resource "aws_ssm_parameter" "rds_username" {
#   name  = "/rds/db_username"
#   type  = "SecureString"
#   value = random_string.rds_username.result
# }


# Store generated DB password in AWS SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name  = "/proj1/db_password"
  type  = "SecureString"
  value = random_password.rds_password.result
}

# Create the RDS PostgreSQL instance
resource "aws_db_instance" "rds_instance" {
  identifier              = var.db_name
  allocated_storage       = var.db_allocated_storage
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  password                = random_password.rds_password.result
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  publicly_accessible     = false
  vpc_security_group_ids = var.vpc_security_group_ids


}

# Store DB hostname in AWS SSM Parameter Store
resource "aws_ssm_parameter" "rds_hostname" {
  name  = "/proj1/db_hostname"
  type  = "String"
  value = aws_db_instance.rds_instance.endpoint  # Replace with your RDS instance resource
}

# Store DB username in AWS SSM Parameter Store
resource "aws_ssm_parameter" "rds_username" {
  name  = "/proj1/db_username"
  type  = "SecureString"
  value = var.db_username  
}
