/*
resource "local_file" "foo" {
  content  = "Hello, World!"
  filename = "${path.module}/removed-block.txt"
}
*/


removed {
  from = local_file.foo
  lifecycle {
    destroy = false
  }
}