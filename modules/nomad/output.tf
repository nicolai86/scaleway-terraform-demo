output "public_ips" {
  value = "${join(",", scaleway_server.server.*.ipv4_address_public)}"
}
