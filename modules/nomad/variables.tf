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
