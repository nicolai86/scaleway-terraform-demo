output "server_ip" {
  value = "${scaleway_server.server.0.private_ip}"
}
