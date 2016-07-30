variable "nomad_ports" {
  # http 4646
  # rpc 4647
  # serf 4648
  default = [4646, 4647, 4648]
}

# security group rules seem to work like iptables: the order of
# accept and drop is important. also, the security groups should be created
# before you start spawning any servers
resource "scaleway_security_group" "cluster" {
  name        = "cluster"
  description = "cluster-sg"
}

# allow datacenter internal traffic to consul:
resource "scaleway_security_group_rule" "accept-internal" {
  security_group = "${scaleway_security_group.cluster.id}"

  action    = "accept"
  direction = "inbound"

  # NOTE this is just a guess - might not work for you.
  ip_range = "10.1.0.0/16"
  protocol = "TCP"
  port     = "${element(var.nomad_ports, count.index)}"
  count    = "${length(var.nomad_ports)}"
}

# disable datacenter external traffic to consul
resource "scaleway_security_group_rule" "drop-external" {
  security_group = "${scaleway_security_group.cluster.id}"

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"

  port  = "${element(var.nomad_ports, count.index)}"
  count = "${length(var.nomad_ports)}"

  depends_on = ["scaleway_security_group_rule.accept-internal"]
}

output "id" {
  value = "${scaleway_security_group.cluster.id}"
}
