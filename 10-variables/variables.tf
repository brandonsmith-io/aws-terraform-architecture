variable "vpn_ip" {
  default = "200.20.30.50/32"
  description = "this is a vpn server created in AWS"
}

variable "app_port" {
  default = "8080"
  description = "Target application listening port"
}

variable "ssh_port" {
  default = "22"
  description = "Secure Shell ingress port for management"
}

variable "ftp_port" {
  default = "21"
  description = "File Transfer Protocol listening port"
}