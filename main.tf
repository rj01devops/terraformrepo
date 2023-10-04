terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}
provider "aws" {
access_key = "AKIAYOBXMZNGRNKU4CHA"
secret_key = "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"
  region     = "ap-south-1"
}
resource "aws_instance" "webec2" {
  ami           = "ami-067c21fb1979f0b27"
  instance_type = "t2.micro"
  vpc_security_group_ids=[aws_security_group.server-sg.id]
  key_name="terrakey"

tags={
 Name="web-server"
}
user_data= <<-EOF
#!/bin/bash
yum install nginx -y
service nginx start
cd /usr/share/nginx/html
touch index.html
echo "hello from terraform" > index.html
EOF
}
resource "aws_security_group" "server-sg" {
 name="server-sg"
ingress {
 from_port=80
 to_port=80
protocol="tcp"
cidr_blocks= ["0.0.0.0/0"]
}

ingress {
 from_port=22
 to_port=22
protocol="tcp"
cidr_blocks= ["0.0.0.0/0"]
}
egress {
 from_port=0
 to_port=0
protocol="-1"
cidr_blocks= ["0.0.0.0/0"]
}
}
resource "aws_key_pair" "terrakey" {
key_name = "terrakey"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tfkey" {
content  = tls_private_key.rsa.private_key_pem
filename = "terrakey"
}
