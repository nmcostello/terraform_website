variable "project" {
  type        = string
  description = "Name for the project to be deployed"
  default     = "hello-world"
}

variable "vpc_id" {
  type        = string
  description = "VPC to deploy to"
}

variable "domain" {
  type        = string
  description = "Domain to deploy webservers to"
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for the web server. Defaulted to a smaller one for testing."
  default     = "t2.micro"
}

variable "min_asg_size" {
  type        = number
  description = "Minimum size for the Autoscaling group"
  default     = 1
}

variable "max_asg_size" {
  type        = number
  description = "Maximum size for the Autoscaling group"
  default     = 10
}

variable "desired_asg_size" {
  type        = number
  description = "Desired size for the Autoscaling group"
  default     = 2
}