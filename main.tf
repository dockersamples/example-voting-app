provider "aws" {
  region = "us-east-1" # Specify your desired AWS region
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "your-unique-bucket-name" # Specify a globally unique bucket name
  acl    = "private" # Specify the ACL (Access Control List) for the bucket
}
