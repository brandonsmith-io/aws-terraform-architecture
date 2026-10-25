provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "myec2" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "t2.micro"
  key_name               = "terraform-key"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  lifecycle {
    ignore_changes = [ami]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/terraform-key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "provisioner-sg"
  description = "Security group for EC2 provisioner"
  vpc_id      = aws_default_vpc.default.id


}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # Semantically equivalent to all ports and protocols
}



output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.myec2.public_ip
}

output "web_url" {
  description = "Direct URL to the Nginx web server"
  value       = "http://${aws_instance.myec2.public_ip}"
}