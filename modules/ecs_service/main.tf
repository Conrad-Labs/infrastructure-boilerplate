terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = var.task_def_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  dynamic "service_connect_configuration" {

    for_each = var.service_connect_enable ? ["true"] : []
    content {
      enabled   = true
      namespace = var.ecs_namespace
      service {
        port_name = var.container_portname
        client_alias {
          dns_name = var.dns_name
          port     = var.proxy_port
        }
      }
    }
  }

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
  dynamic "load_balancer" {
    for_each = var.loadblancer_required ? ["true"] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}