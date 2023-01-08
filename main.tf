terraform {
  backend "s3" {
    bucket   = "challenge-tf-state"
    key      = "terraform.tfstate"
  }
}


# Configure the web server autoscaling group
resource "aws_autoscaling_group" "web" {
  name                 = "${var.project}-asg"
  min_size             = var.min_asg_size
  max_size             = var.max_asg_size
  desired_capacity     = var.desired_asg_size
  vpc_zone_identifier  = var.private_subnets
  launch_configuration = aws_launch_configuration.web.name

  # Add any other required configuration for the autoscaling group here
}

# Configure the launch configuration for the web server
resource "aws_launch_configuration" "web" {
  name                        = "${var.project}-lc"
  image_id                    = "ami-12345678"
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.web.id]
  associate_public_ip_address = true

  # Add any other required configuration for the launch configuration here
}

# Create a security group for the web servers
resource "aws_security_group" "web" {
  name        = "${var.project}-sg"
  description = "Security group for the web servers"

  # Add any required ingress/egress rules here
}

# Create a security group for the load balancer
resource "aws_security_group" "lb" {
  name        = "${var.project}-sg"
  description = "Security group for the load balancer"

  # Add any required ingress/egress rules here
}

# Create the load balancer
resource "aws_lb" "web" {
  name            = "${var.project}-lb"
  security_groups = [aws_security_group.lb.id]

  subnets = [for subnet in aws_subnet.public : subnet.id]

  # Add any other required configuration for the load balancer here

}
# Enable HTTPS listener on port 443
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  certificate_arn   = aws_acm_certificate.ssl.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = 443
      status_code = "HTTP_301"
    }
  }
}

# Create a target group for the web server
resource "aws_lb_target_group" "web" {
  name        = var.project
  port        = 443
  protocol    = "HTTP"
  target_type = "instance"

  # Add the web server autoscaling group as a target
  targets {
    id = aws_autoscaling_group.web.arn
  }
}

# Create an SSL certificate
resource "aws_acm_certificate" "ssl" {
  domain_name       = aws_lb.web.dns_name
  validation_method = "DNS"

  depends_on = [
    aws_lb.web
  ]
}
