variable "s3_bucket_domain" {
  type = string
}

# variable "domain_name" {
#   description = "The domain name for CloudFront"
#   type        = string
# }

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "alias" {
  type = list(string)
  nullable = false
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}


