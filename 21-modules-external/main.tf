module "ec2-instance" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  version       = "6.4.1"
  subnet_id     = "subnet-03c71550cbe886b1a"
  instance_type = "t2.micro"

}