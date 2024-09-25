output "bastion_instance_id" {
  description = "The ID of the Bastion Host EC2 instance."
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion Host."
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_key_pem" {
  description = "The private key to SSH into the Bastion Host."
  value       = tls_private_key.bastion.private_key_pem
  sensitive   = true
}
