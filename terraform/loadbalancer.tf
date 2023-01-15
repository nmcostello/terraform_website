# Create a security group for the load balancer
resource "aws_security_group" "lb" {
  name        = "${var.project}-lb-sg"
  description = "Security group for the load balancer"

  # Add any required ingress/egress rules here
  ingress {
    description = "Only allow https traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create the load balancer
resource "aws_lb" "web" {
  name            = "${var.project}-lb"
  security_groups = [aws_security_group.lb.id]
  subnets         = toset(data.aws_subnets.public.ids)
  # Add any other required configuration for the load balancer here
}
# route53 record pointing to lb 
resource "aws_route53_record" "lb" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.domain}.${data.aws_route53_zone.public.name}"
  type    = "CNAME"
  records = [aws_lb.web.dns_name]
  ttl     = "120"
}

# Enable redirect 80->443
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = 443
      status_code = "HTTP_301"
    }
  }
}

# Enable HTTPS listener on port 443
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web.arn
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.lb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Create a target group for the web server
resource "aws_lb_target_group" "web" {
  name        = var.project
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}