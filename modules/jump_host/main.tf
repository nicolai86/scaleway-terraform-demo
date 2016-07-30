variable "image" {
  default     = "eeb73cbf-78a9-4481-9e38-9aaadaf8e0c9"
  description = "Ubuntu 16.04 ARM; if you change the instance type be sure to adjust this."
}

variable "security_group" {
  description = "Security Group to place servers in"
}

variable "type" {
  default     = "C1"
  description = "Scaleway Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

resource "scaleway_server" "jump_host" {
  name                = "jump_host"
  image               = "${var.image}"
  type                = "${var.type}"
  dynamic_ip_required = true

  tags = ["jump_host"]

  security_group = "${var.security_group}"
}

resource "scaleway_ip" "jump_host" {
  server = "${scaleway_server.jump_host.id}"
}

output "public_ip" {
  value = "${scaleway_ip.jump_host.ip}"
}
