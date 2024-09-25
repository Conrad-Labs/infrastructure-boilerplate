terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }

}

resource "aws_lb" "ALB" {
  name = var.elb-name
  internal = false
  load_balancer_type = "application"
  security_groups = var.security_groups
  subnets = var.subnets
}

resource "aws_lb_target_group" "target_group" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    path = var.health_check_path
    timeout = var.health_check_timeout
    interval = var.health_check_interval
    healthy_threshold = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.listener_cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

 
  

  
}