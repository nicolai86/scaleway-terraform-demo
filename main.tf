provider "scaleway" {}

module "consul" {
  source = "./modules/consul"
}

