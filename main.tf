terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.15.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "linux-2023" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "name"
        values = ["al2023-ami-2023*"]
  }
}

resource "aws_security_group" "ec2-sec-grp" {
    name = "ec2-sec-grp"
    description = "Allow TLS inbound traffic"

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "docker-instance" {
    ami = data.aws_ami.linux-2023.image_id
    instance_type = "t2.micro"
    key_name = "usa_key"
    vpc_security_group_ids = [aws_security_group.ec2-sec-grp.id]
    user_data = <<-EOF
                #!/bin/bash
                dnf update -y
                dnf install docker -y
                systemctl start docker
                systemctl enable docker
                usermod -a -G docker ec2-user
                newgrp docker
                sleep 3
                cd /home/ec2-user
                docker container run --name -deneme -dp 80:80 esra/nginx-website
                EOF
}

output "dns-name" {
  value = "http://${aws_instance.docker-instance.public_ip}"
}