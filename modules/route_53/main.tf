terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }

}
resource "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "this" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = "A"

  # Optional: If you want to use CloudFront as an alias target
  alias {
    name                   = var.alias_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}




    