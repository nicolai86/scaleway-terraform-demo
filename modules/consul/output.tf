output "server_ip" {
  value = "${scaleway_server.server.0.ipv4_address_private}"
}
