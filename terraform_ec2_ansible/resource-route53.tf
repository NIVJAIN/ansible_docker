data "aws_route53_zone" "ecs_domain" {
  name         = local.domain_name
  private_zone = false
}

data "aws_acm_certificate" "ecs_domain_certificate" {
  domain      = "*.${local.domain_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

output "route53" {
  value = data.aws_acm_certificate.ecs_domain_certificate
}