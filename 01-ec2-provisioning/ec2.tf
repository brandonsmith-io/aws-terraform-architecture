provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2one" {
  ami           = "ami-0b245cc5f82576748"
  instance_type = "t2.micro"
}
