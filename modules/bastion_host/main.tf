terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }

}

# Security Group for Bastion Host #If you change your sg module please change this too 
resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Modify this as per your security policy
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.bastion_name}-sg"
  }
}

# Key Pair for SSH Access
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_key" {
  key_name   = var.key_pair
  public_key = tls_private_key.bastion.public_key_openssh
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami
  instance_type          = var.bastion_instance_type
  subnet_id              = var.public_subnet_id
  key_name               = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

}

# Saving Key Pair for ssh login for Client if needed
resource "null_resource" "save_key_pair"  {
	provisioner "local-exec" {
	    command = "echo  ${tls_private_key.bastion.private_key_pem} > mykey.pem"
  	}
}

# # Output the private key for SSH access
# output "bastion_private_key_pem" {
#   value     = tls_private_key.bastion.private_key_pem
#   sensitive = true
# }

# output "bastion_instance_id" {
#   value       = aws_instance.bastion.id
#   description = "The ID of the Bastion Host EC2 instance."
# }

# output "bastion_public_ip" {
#   value       = aws_instance.bastion.public_ip
#   description = "The public IP of the Bastion Host."
# }


#Pass in secret manager parameter store 