variable "commercial_type" {
  default = "C1"
}

variable "architectures" {
  default = {
    C1   = "arm"
    VC1S = "x86_64"
    VC1M = "x86_64"
    VC1L = "x86_64"
    C2S  = "x86_64"
    C2M  = "x86_64"
    C2L  = "x86_64"
  }
}

data "scaleway_image" "ubuntu" {
  architecture = "${lookup(var.architectures, var.commercial_type)}"
  name = "Ubuntu Xenial"
}

provider "scaleway" {}

module "security_group" {
  source = "./modules/security_group"
}

module "jump_host" {
  source = "./modules/jump_host"

  security_group = "${module.security_group.id}"

  type  = "${var.commercial_type}"
  image = "${data.scaleway_image.ubuntu.id}"
}

module "consul" {
  source = "./modules/consul"

  security_group = "${module.security_group.id}"
  bastion_host   = "${module.jump_host.public_ip}"

  type  = "${var.commercial_type}"
  image = "${data.scaleway_image.ubuntu.id}"
}

module "nomad" {
  source            = "./modules/nomad"
  consul_cluster_ip = "${module.consul.server_ip}"
  security_group    = "${module.security_group.id}"

  type  = "${var.commercial_type}"
  image = "${data.scaleway_image.ubuntu.id}"
}
