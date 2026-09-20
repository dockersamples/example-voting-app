# Route 53 DNS Record for Vote Web App
resource "aws_route53_record" "vote" {
  zone_id = local.route53_zone_id
  name    = "${var.vote_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

# Route 53 DNS Record for Result Web App
resource "aws_route53_record" "result" {
  zone_id = local.route53_zone_id
  name    = "${var.result_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
