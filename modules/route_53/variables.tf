variable "domain_name" {
  description = "The domain name for the Route 53 hosted zone."
  type        = string
}

# variable "record_name" {
#   description = "The name of the DNS record."
#   type        = string
# }

# variable "ttl" {
#   description = "The TTL of the DNS record."
#   type        = number
#   default     = 300
# }

variable "records" {
  description = "A list of records to create in Route 53."
  type = list(object({
    name                   = string
    alias_name             = string
    alias_zone_id          = string
    evaluate_target_health = bool
  }))
}

# variable "alias_name" {
#   description = "The DNS name for the alias target (e.g., CloudFront distribution)."
#   type        = string
# }

# variable "alias_zone_id" {
#   description = "The zone ID for the alias target (e.g., CloudFront distribution zone ID)."
#   type        = string
# }

# variable "evaluate_target_health" {
#   description = "Whether to evaluate the target health when routing traffic to an alias record."
#   type        = bool
#   default     = false
# }

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

