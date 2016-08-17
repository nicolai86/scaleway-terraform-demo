provider "scaleway" {}

module "security_group" {
  source = "./modules/security_group"
}

module "jump_host" {
  source = "./modules/jump_host"

  security_group = "${module.security_group.id}"
}

module "consul" {
  source = "./modules/consul"

  security_group = "${module.security_group.id}"
  bastion_host   = "${module.jump_host.public_ip}"
}

module "nomad" {
  source            = "./modules/nomad"
  consul_cluster_ip = "${module.consul.server_ip}"
  security_group    = "${module.security_group.id}"
}
