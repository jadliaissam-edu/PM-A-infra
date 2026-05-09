output "db_server_ip" {
  description = "Public IPv4 address of the PostgreSQL server"
  value       = hcloud_server.db.ipv4_address
}

output "db_private_ip" {
  description = "Private IPv4 address of the PostgreSQL server"
  value       = tolist(hcloud_server.db.network)[0].ip
}

output "db_volume_id" {
  description = "ID of the persistent data volume"
  value       = hcloud_volume.db_data.id
}