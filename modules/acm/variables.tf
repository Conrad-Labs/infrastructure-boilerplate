variable "region" {
  description = "The AWS region."
  type        = string
  default     = "us-east-2"
}

variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
}


variable "route53_zone_id" {
  description = "The Route53 Zone ID where the domain is hosted"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

