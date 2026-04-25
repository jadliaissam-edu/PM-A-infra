resource "hcloud_server" "app" {
  count = var.server_count

  name        = "${var.environment}-server"
  server_type = "cx11"
  image       = "debian-11"
  location    = "nbg1"
  labels = {
    environment = var.environment
  }

  network {
    network_id = module.network.network_id
  }
}