# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "challenge-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Get public and private subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Tier = "private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Tier = "public"
  }
}

# data "aws_ami" "packer" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"]
# }

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

resource "aws_acm_certificate" "lb" {
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "public" {
  name         = var.domain
  private_zone = false
  vpc_id       = var.vpc_id
}

resource "aws_route53_record" "validation" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = aws_acm_certificate.lb.domain_validation_options.resource_record_name
  type    = aws_acm_certificate.lb.domain_validation_options.resource_record_type
  records = [aws_acm_certificate.lb.domain_validation_options.resource_record_value]
  ttl     = "300"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.lb.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
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

# Configure the web server autoscaling group
resource "aws_autoscaling_group" "web" {
  name                 = "${var.project}-asg"
  min_size             = var.min_asg_size
  max_size             = var.max_asg_size
  desired_capacity     = var.desired_asg_size
  vpc_zone_identifier  = toset(data.aws_subnets.private.ids)
  launch_configuration = aws_launch_configuration.web.name
  load_balancers       = [aws_lb.web.name]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_lb.web
  ]

}

# Configure the launch configuration for the web server
resource "aws_launch_configuration" "web" {
  name = "${var.project}-lc"
  # image_id                    = data.aws_ami.packer
  image_id                    = "ami-02fe94dee086c0c37"
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.web.id]
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }

  # Add any other required configuration for the launch configuration here
}

# Create a security group for the web servers
resource "aws_security_group" "web" {
  name        = "${var.project}-web-sg"
  description = "Security group for the web servers"

  # Allow ingress only from the LB
  ingress {
    description     = "Traffic from LB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}