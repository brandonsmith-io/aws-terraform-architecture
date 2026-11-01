provider "aws" {
  region = "us-east-1"
}


import {
  to = aws_security_group.mysg
  id = "sg-0f9cb1823f10bf518"
}