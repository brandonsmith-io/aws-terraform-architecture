variable "enviroment" {
  default = "production"
}

variable "region" {
  default = "ap-south-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = var.enviroment == "production" && var.region == "us-east-1" ? "t2.micro" : "m5.large"
}