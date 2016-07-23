output "public_ips" {
  value = "${join(",", scaleway_server.server.*.public_ip)}"
}
