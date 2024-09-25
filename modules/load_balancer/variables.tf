variable "elb-name" {
  type = string
  nullable = false
}

variable "security_groups" {
  type = list(string)
  nullable = false
}

variable "subnets" {
  type = list(string)
  nullable = false
}

variable "target_group_name" {
  type = string
  nullable = false
}

variable "target_group_port" {
  type = number
  default = 80
}

variable "target_group_protocol" {
  type = string
  default = "HTTP"
}

variable "vpc_id" {
  type = string
  nullable = false
}

variable "listener_port" {
  type = string
  default = "80"
}

variable "listener_protocol" {
  type = string
  default = "HTTP"
}

variable "ssl_policy" {
  type = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "certificate_arn" {
  type = string
  default = null
}


variable "health_check_path" {
  type = string
  nullable = false
}

variable "health_check_timeout" {
  type = number
  default = 5
}

variable "health_check_interval" {
  description = "The health check interval"
  default     = 30
}

variable "healthy_threshold" {
  description = "The healthy threshold"
  default     = 2
}

variable "unhealthy_threshold" {
  description = "The unhealthy threshold"
  default     = 2
}

variable "listener_cert_arn" {
  type = string
  nullable = false
}

variable "tags" {}
