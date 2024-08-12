provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "bad_sg" {
  name        = "bad_security_group"
  description = "Security group with overly permissive rules"
  vpc_id      = "vpc-123456"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "bad_bucket" {
  bucket = "bad-bucket"
  
  acl    = "public-read" # S3 bucket with public read access
}

resource "aws_instance" "bad_instance" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "This is a test" > /tmp/test.txt
              EOF

  tags = {
    Name = "BadInstance"
  }
}
