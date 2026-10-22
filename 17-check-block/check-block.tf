check "website_check" {
  data "http" "example" {
    url = "https://google.com323"
  }

  assert {
    condition     = data.http.example.status_code == 200
    error_message = "website is down and not running, please check again later"
  }
}


resource "local_file" "foo" {
  content  = "hi"
  filename = "${path.module}/foo.txt"
}