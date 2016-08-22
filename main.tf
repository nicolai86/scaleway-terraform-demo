variable "commercial_type" {
  default = "C1" # VC1S, C2S
}

variable "images" {
  default = {
    C1   = "eeb73cbf-78a9-4481-9e38-9aaadaf8e0c9"
    VC1S = "75c28f52-6c64-40fc-bb31-f53ca9d02de9"
    C2S  = "75c28f52-6c64-40fc-bb31-f53ca9d02de9"
  }
}

provider "scaleway" {}

module "security_group" {
  source = "./modules/security_group"
}

module "jump_host" {
  source = "./modules/jump_host"

  security_group = "${module.security_group.id}"

  type  = "${var.commercial_type}"
  image = "${lookup(var.images, var.commercial_type)}"
}

module "consul" {
  source = "./modules/consul"

  security_group = "${module.security_group.id}"
  bastion_host   = "${module.jump_host.public_ip}"

  type  = "${var.commercial_type}"
  image = "${lookup(var.images, var.commercial_type)}"
}

module "nomad" {
  source            = "./modules/nomad"
  consul_cluster_ip = "${module.consul.server_ip}"
  security_group    = "${module.security_group.id}"

  type  = "${var.commercial_type}"
  image = "${lookup(var.images, var.commercial_type)}"
}
