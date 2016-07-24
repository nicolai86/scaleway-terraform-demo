variable "consul_ports" {
  # server 8300
  # serf lan 8301
  # serf wan 8302
  # rpc 8400
  # http 8500
  # dns 8600
  default = [8300, 8301, 8302, 8400, 8500, 8600]
}

variable "nomad_ports" {
  # http 4646
  # rpc 4647
  # serf 4648
  default = [4646, 4647, 4648]
}
