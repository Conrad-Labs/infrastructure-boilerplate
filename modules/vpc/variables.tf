variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "azs" {
  description = "The availability zones to deploy the resources."
  default     = ["us-east-2a", "us-east-2b"]
}

variable "tags" {}
