terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }
}

resource "hcloud_volume" "app_storage" {
  name     = "${var.environment}-app-storage"
  size     = 100
  location = var.location
  format   = "ext4"

  labels = {
    environment = var.environment
    role        = "storage"
  }
}
