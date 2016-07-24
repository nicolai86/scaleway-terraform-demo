# security group rules seem to work like iptables: the order of
# accept and drop is important. also, the security groups should be created
# before you start spawning any servers
resource "scaleway_security_group" "cluster" {
  name        = "cluster"
  description = "cluster-sg"
}

# allow datacenter internal traffic to consul:
resource "scaleway_security_group_rule" "accept-consul-internal" {
  security_group = "${scaleway_security_group.cluster.id}"

  action    = "accept"
  direction = "inbound"

  # NOTE this is just a guess - might not work for you.
  ip_range = "10.1.0.0/16"
  protocol = "TCP"
  port     = "${element(concat(var.consul_ports, var.nomad_ports), count.index)}"
  count    = "${length(concat(var.consul_ports, var.nomad_ports))}"
}

# disable datacenter external traffic to consul
resource "scaleway_security_group_rule" "drop-consul-external" {
  security_group = "${scaleway_security_group.cluster.id}"

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"

  port  = "${element(concat(var.consul_ports, var.nomad_ports), count.index)}"
  count = "${length(concat(var.consul_ports, var.nomad_ports))}"

  depends_on = ["scaleway_security_group_rule.accept-consul-internal"]
}
