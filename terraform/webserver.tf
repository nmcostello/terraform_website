data "aws_ami" "packer" {
  most_recent = true

  filter {
    name   = "name"
    values = ["noah-challenge-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

# Configure the web server autoscaling group
resource "aws_autoscaling_group" "web" {
  name                 = "${var.project}-asg"
  min_size             = var.min_asg_size
  max_size             = var.max_asg_size
  desired_capacity     = var.desired_asg_size
  vpc_zone_identifier  = toset(data.aws_subnets.public.ids)
  launch_configuration = aws_launch_configuration.web.name
  target_group_arns    = [aws_lb_target_group.web.arn]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_lb.web
  ]

}

# Configure the launch configuration for the web server
resource "aws_launch_configuration" "web" {
  image_id                    = data.aws_ami.packer.image_id
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