/*
variable "password" {
    default = "my_secret_password"
    sensitive = true
}
*/

resource "local_sensitive_file" "foo" {
  content  = "my_secret_password"
  filename = "password.txt"
}

output "pass" {
  value = local_sensitive_file.foo.content
  sensitive = true
}

variable "db_user" {
    default = "admin"
    sensitive = true
}
    
   
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_user
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}