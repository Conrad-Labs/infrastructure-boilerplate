variable "domain_name" {
  description = "The domain name for the Route 53 hosted zone."
  type        = string
}

variable "record_name" {
  description = "The name of the DNS record."
  type        = string
}

variable "ttl" {
  description = "The TTL of the DNS record."
  type        = number
  default     = 300
}

variable "records" {
  description = "The IP addresses to associate with the A record. This should be an empty list if using alias."
  type        = list(string)
  default     = []
}

variable "alias_name" {
  description = "The DNS name for the alias target (e.g., CloudFront distribution)."
  type        = string
}

variable "alias_zone_id" {
  description = "The zone ID for the alias target (e.g., CloudFront distribution zone ID)."
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether to evaluate the target health when routing traffic to an alias record."
  type        = bool
  default     = false
}

variable "tags" {}
