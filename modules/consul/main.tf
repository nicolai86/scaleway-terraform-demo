variable "server_count" {
  default     = "2"
  description = "The number of Consul servers to launch."
}

variable "image" {
  default     = "eeb73cbf-78a9-4481-9e38-9aaadaf8e0c9"
  description = "Ubuntu 16.04 ARM; if you change the instance type be sure to adjust this."
}

variable "type" {
  default     = "C1"
  description = "Scaleway Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "security_group" {
  description = "Security Group to place servers in"
}

variable "bastion_host" {
  description = "IP of bastion host used for provisioning"
}

resource "scaleway_server" "server" {
  count = "${var.server_count}"
  name  = "consul-${count.index + 1}"
  image = "${var.image}"
  type  = "${var.type}"

  tags = ["consul"]

  connection {
    type         = "ssh"
    user         = "root"
    host         = "${self.private_ip}"
    bastion_host = "${var.bastion_host}"
    bastion_user = "root"
    agent        = true
  }

  # provisioner "file" {
  #   source      = "${path.module}/scripts/upstart.conf"
  #   destination = "/tmp/upstart.conf"
  # }
  provisioner "file" {
    source      = "${path.module}/scripts/system.service"
    destination = "/tmp/consul.service"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.server_count} > /tmp/consul-server-count",
      "echo ${scaleway_server.server.0.private_ip} > /tmp/consul-server-addr",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install.sh",
      "${path.module}/scripts/service.sh",
    ]
  }

  security_group = "${var.security_group}"
}

output "server_ip" {
  value = "${scaleway_server.server.0.private_ip}"
}
