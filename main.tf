terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "inventory_tracker" {
  name_prefix = "inventory-tracker-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "inventory-tracker-sg"
  }
}

resource "aws_instance" "inventory_tracker" {
  ami           = "ami-0bb7d855677353076"
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.inventory_tracker.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))

  tags = {
    Name = "inventory-tracker"
  }
}

output "instance_id" {
  value = aws_instance.inventory_tracker.id
}

output "public_ip" {
  value = aws_instance.inventory_tracker.public_ip
}

output "public_dns" {
  value = aws_instance.inventory_tracker.public_dns
}