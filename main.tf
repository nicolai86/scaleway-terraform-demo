provider "scaleway" {}

module "consul" {
  source = "./modules/consul"
}

module "nomad" {
  source            = "./modules/nomad"
  consul_cluster_ip = "${module.consul.server_ip}"
}

