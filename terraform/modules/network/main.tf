terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }
}

resource "hcloud_network" "vpc" {
  name = "${var.environment}-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.vpc.id
  ip_range     = "10.0.1.0/24"
  network_zone = "eu-central"
  type         = "cloud"
}