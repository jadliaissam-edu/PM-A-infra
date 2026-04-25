resource "hcloud_network" "vpc" {
  name = "${var.environment}-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_subnetwork" "subnet" {
  network_id = hcloud_network.vpc.id
  ip_range   = "10.0.1.0/24"
}