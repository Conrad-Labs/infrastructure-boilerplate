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
  for_each = { for rec in var.records : rec.name => rec }

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = "A"

  alias {
    name                   = each.value.alias_name
    zone_id                = each.value.alias_zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}





    