provider "scaleway" {}

module "consul" {
  source = "./modules/consul"
}

module "nomad" {
  source            = "./modules/nomad"
  consul_cluster_ip = "${module.consul.server_ip}"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_route53_record" "service" {
  zone_id = "${var.aws_hosted_zone_id}"
  name    = "isgo17outyet"
  type    = "A"
  ttl     = "30"

  records = [
    "${split(",", module.nomad.public_ips)}",
  ]
}
