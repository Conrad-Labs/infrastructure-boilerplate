output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.ecs_service.name
}

# output "ecs_service_arn" {
#   description = "The ARN of the ECS service."
#   value       = aws_ecs_service.ecs_service.arn
# }

output "ecs_service_cluster" {
  description = "The ARN of the ECS cluster the service is running on."
  value       = aws_ecs_service.ecs_service.cluster
}