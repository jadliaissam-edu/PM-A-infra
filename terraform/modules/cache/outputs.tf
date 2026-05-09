output "cache_server_ip" {
  description = "Public IPv4 address of the Redis server"
  value       = hcloud_server.cache.ipv4_address
}

output "cache_private_ip" {
  description = "Private IPv4 address of the Redis server"
  value       = tolist(hcloud_server.cache.network)[0].ip
}
