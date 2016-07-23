resource "scaleway_server" "server" {
  count               = "${var.server_count}"
  name                = "consul-${count.index + 1}"
  image               = "${var.image}"
  type                = "${var.type}"
  dynamic_ip_required = true

  tags = ["consul"]

  # provisioner "file" {
  #   source      = "${path.module}/scripts/debian_upstart.conf"
  #   destination = "/tmp/upstart.conf"
  # }
  provisioner "file" {
    source      = "${path.module}/scripts/rhel_system.service"
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
}
