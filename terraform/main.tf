terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
    backend "s3" {
        key = "aws/ec2-deploy/terraform.tfstate"
    }
}

provider "aws" {
    region = var.region

}
resource "aws_instance" "server" {
    ami = "ami-0a0e5d9c7acc336f1"
    instance_type = "t2.micro"
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [ aws_security_group.maingroup.id ]
    iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = var.private_key
        timeout = "4m"
    }
    tags = {
      "name" = "DeployVM"
    }
} 
resource "aws_iam_instance_profile" "ec2-profile" {
    name = "ec2-profile"
    role = "EC2-ECR-AUTH"
}
resource "aws_security_group" "maingroup" {
  name        = "my-security-group"
  description = "My security group"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

    ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
}

resource "aws_key_pair" "deployer" {
    key_name = var.key_name
    public_key = var.public_key
}

output "instance_public_ip" {
    value = aws_instance.server.public_ip
    sensitive = true
}