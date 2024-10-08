variable "db_name" {
  default = "mydb"
}

variable "db_username" {
  default = "admin"
}

# variable "db_password" {
#   description = "The password for the RDS database."
#   sensitive   = true
# }

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  default = 20
}

variable "db_engine_version" {
  default = "13.4"
}

variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be deployed."
}

variable "subnet_ids" {
  type = list(string)
  description = "The private subnets where the RDS instance will be deployed."
}

# variable "db_subnet_group_name" {}

variable "db_backup_retention_period" {
  default = 7
}

variable "db_skip_final_snapshot" {
  default = true
}

variable "db_multi_az" {
  default = false
}

variable "vpc_security_group_ids" {
  description = "List of VPC Security Group IDs to attach to the RDS instance"
  type        = list(string)
}
