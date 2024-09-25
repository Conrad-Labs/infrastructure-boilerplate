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
  name       = var.db_subnet_group_name
  subnet_ids = var.private_subnets

  tags = {
    Name = "RDS subnet group"
  }
}


# Create the RDS PostgreSQL instance
resource "aws_db_instance" "rds_instance" {
  identifier              = var.db_name
  allocated_storage       = var.db_allocated_storage
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  publicly_accessible     = false
}

