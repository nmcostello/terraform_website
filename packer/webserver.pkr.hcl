packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "noah-challenge"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
    
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }

  provisioner "file" {
    source      = "website"
    destination = "/tmp/website"
  }

  provisioner "shell" {

    inline = [
      "echo Installing NGINX server...",
      "sleep 10",
      "sudo apt update",
      "sudo apt install -y nginx",
      "echo Install of NGINX successful...",
      "echo Creating site directory...",
      "sudo mkdir -p /var/www/website",
      "sudo cp /tmp/index.html /var/www/website/index.html",
      "sudo cp /tmp/website /etc/nginx/site-enabled/website",
      "sudo service nginx enable",
      "sudo service nginx restart",
    ]
  }
}
