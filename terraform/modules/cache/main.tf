terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }
}

resource "hcloud_server" "cache" {
  name        = "${var.environment}-redis"
  server_type = var.server_type
  image       = "ubuntu-22.04"
  location    = var.location

  user_data = <<-EOF
    #cloud-config
    users:
      - name: deploy
        groups: sudo
        shell: /bin/bash
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    ssh_pwauth: false
    disable_root: true
  EOF

  labels = {
    environment = var.environment
    tier        = "data"
    role        = "cache"
  }

  network {
    network_id = var.network_id
  }
}
