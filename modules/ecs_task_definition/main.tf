terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }

}

resource "aws_ecs_task_definition" "ecs_task_def" {
    family = var.task_name
    execution_role_arn = var.execution_role
    task_role_arn = var.execution_role
    requires_compatibilities = [ "FARGATE" ]
    network_mode = "awsvpc"
    cpu = var.cpu_units
    memory = var.memory
    
    container_definitions = jsonencode([
        {
            name = var.container_name
            image = var.docker_image

            environment = var.environment_vars
            secrets     = var.secrets
            portMappings = [
                {
                    name = var.container_portname
                    containerPort = var.container_port
                    hostPort = var.host_port != "" && var.host_port != null ? var.host_port : var.container_port
                }
            ]
          
            logConfiguration = {
              logDriver = "awslogs"
              options = {
                awslogs-group = var.task_name
                awslogs-create-group = "true"
                awslogs-region = "us-east-2"
                awslogs-stream-prefix = "ecs"
              }
            }

            
        }
    ])
  
}