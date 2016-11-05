variable "server_count" {
  default     = "2"
  description = "The number of Consul servers to launch."
}

variable "image" {}

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

  provisioner "local-exec" {
    command = "curl -L -o /tmp/consul_0.6.4_amd64.zip https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip"
  }

  provisioner "local-exec" {
    command = "curl -L -o /tmp/consul_0.6.4_arm.zip https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_arm.zip"
  }

  provisioner "file" {
    source      = "/tmp/consul_0.6.4_amd64.zip"
    destination = "/tmp/consul_0.6.4_amd64.zip"
  }

  provisioner "file" {
    source      = "/tmp/consul_0.6.4_arm.zip"
    destination = "/tmp/consul_0.6.4_arm.zip"
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
