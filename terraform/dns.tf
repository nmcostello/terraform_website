data "aws_route53_zone" "public" {
  name         = var.domain
  private_zone = false
}

resource "aws_acm_certificate" "lb" {
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = tolist(aws_acm_certificate.lb.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.lb.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.lb.domain_validation_options)[0].resource_record_value]
  ttl     = "120"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.lb.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
}