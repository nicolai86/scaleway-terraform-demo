variable "server_count" {
  default     = "2"
  description = "The number of nomad servers to launch."
}

variable "image" {
  default     = "eeb73cbf-78a9-4481-9e38-9aaadaf8e0c9"
  description = "Ubuntu 16.04 ARM; if you change the instance type be sure to adjust this."
}

variable "type" {
  default     = "C1"
  description = "Scaleway Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "consul_cluster_ip" {
  description = "ip to consul cluster. Port is assumed to be 8500"
}

variable "security_group" {
  description = "Security Group to place servers in"
}

resource "scaleway_server" "server" {
  count               = "${var.server_count}"
  name                = "nomad-${count.index + 1}"
  image               = "${var.image}"
  type                = "${var.type}"
  dynamic_ip_required = true
  tags                = ["cluster"]

  # provisioner "file" {
  #   source      = "${path.module}/scripts/upstart.conf"
  #   destination = "/tmp/upstart.conf"
  # }
  provisioner "file" {
    source      = "${path.module}/scripts/system.service"
    destination = "/tmp/nomad.service"
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/server.hcl <<EOF
datacenter = "dc1"

bind_addr = "${self.private_ip}"

advertise {
  # We need to specify our host's IP because we can't
  # advertise 0.0.0.0 to other nodes in our cluster.
  serf = "${self.private_ip}:4648"
  rpc = "${self.private_ip}:4647"
  http= "${self.private_ip}:4646"
}

server {
  enabled = true
  bootstrap_expect = ${element(split(",", "1,0"), signum(count.index))}
}

client {
  enabled = true
  options = {
    "driver.raw_exec.enable" = "1"
  }
}

consul {
  address = "${var.consul_cluster_ip}:8500"
}
EOF
CMD
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install.sh",
      "${path.module}/scripts/service.sh",
    ]
  }

  security_group = "${var.security_group}"
}

output "public_ips" {
  value = "${join(",", scaleway_server.server.*.public_ip)}"
}
