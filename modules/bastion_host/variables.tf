variable "vpc_id" {
  description = "The VPC ID where the Bastion Host will be deployed."
}

variable "public_subnet_id" {
  description = "The public subnet ID where the Bastion Host will be launched."
}

variable "bastion_instance_type" {
  description = "The EC2 instance type for the Bastion Host."
  default     = "t2.micro"
}

variable "bastion_ami" {
  description = "The AMI ID to use for the Bastion Host."
}

variable "key_pair" {
  description = "The name of the key pair to use for SSH access."
}

# variable "ssh_port" {
#   description = "The SSH port to allow access."
#   default     = 22
# }

variable "bastion_name" {
  description = "The name for the Bastion Host."
  default     = "bastion_host"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

