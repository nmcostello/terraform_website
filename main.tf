####################################
# Author: Noah Costello
# Created: 5 January 2023
# The purpose of this file is to:
# - deploy a scalable web server that:
#     - hosts a static web page
# - put a load balancer in front of the server to:
#     - add SSL
#     - redirect all http to https

# Configure the web server autoscaling group
resource "aws_autoscaling_group" "web" {
  name                  = "${var.project}-asg"
  min_size              = 1
  max_size              = 10
  desired_capacity      = 2
  vpc_zone_identifier   = ["subnet-12345678"]
  launch_configuration = "${aws_launch_configuration.web.name}"

  # Add any other required configuration for the autoscaling group here
}

# Configure the launch configuration for the web server
resource "aws_launch_configuration" "web" {
  name                            = "${var.project}-lc"
  image_id                        = "ami-12345678"
  instance_type                   = "t2.micro"
  security_groups                 = [aws_security_group.web.id]
  associate_public_ip_address     = true

  # Add any other required configuration for the launch configuration here
}

# Create a target group for the web server
resource "aws_lb_target_group" "web" {
  name        = "${var.project}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  # Add the web server autoscaling group as a target
  targets {
    id = "${aws_autoscaling_group.web.arn}"
  }
}

# Create an SSL certificate
resource "aws_acm_certificate" "ssl" {
  domain_name       = "example.com"
  validation_method = "DNS"
}

# Create a security group for the load balancer
resource "aws_security_group" "lb" {
  name        = "${var.project}-sg"
  description = "Security group for the load balancer"

  # Add any required ingress/egress rules here
}

# Create the load balancer
resource "aws_lb" "lb" {
  name            = "${var.project}-lb"
  security_groups = [aws_security_group.lb.id]

  # Add any other required configuration for the load balancer here

  # Enable HTTPS listener on port 443
  https_listener {
    port               = 443
    certificate_arn    = aws_acm_certificate.ssl.arn
    ssl_policy         = "ELBSecurityPolicy-TLS-1-2-2017-01"
    default_action {
      type = "redirect"
      redirect {
        protocol = "HTTPS"
        port     = 443
        host     = "#{aws_lb.lb.dns_name}"
        path     = "/#{uri}"
        query    = "#{query}"
        status   = "HTTP_301"
      }
    }
  }
}

# Create a listener rule to redirect HTTP traffic to HTTPS
resource "aws_lb_listener_rule" "redirect" {
  listener_arn = aws_lb.lb.https_listener_arn
  priority     = 1

  action {
    type             = "redirect"
    redirect {
      protocol        = "HTTPS"
      port            = 443
      host            = "#{aws_lb.lb.dns_name}"
      path            = "/#{uri}"
      query           = "#{query}"
      status_code     = "HTTP_301"
    }
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }

  # Add the target group as a condition
  condition {
    field  = "host-header"
    values = [aws_lb_target_group.web.dns_name]
  }
}
