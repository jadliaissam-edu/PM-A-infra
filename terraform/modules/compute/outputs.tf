output "instance_ips" {
  description = "Public IPv4 addresses of the application servers"
  value       = hcloud_server.app[*].ipv4_address
}

output "private_ips" {
  description = "Private IPv4 addresses of the application servers"
  value       = [for s in hcloud_server.app : tolist(s.network)[0].ip]
}