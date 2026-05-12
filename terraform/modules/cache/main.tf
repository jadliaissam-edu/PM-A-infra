terraform {

  required_providers {

    hcloud = {

      source = "hetznercloud/hcloud"

    }

  }

}



resource "hcloud_server" "cache" {

  name        = "${var.environment}-redis"

  server_type = var.server_type

  image       = "ubuntu-22.04"

  location    = var.location

  ssh_keys    = [var.ssh_key_id]



  labels = {

    environment = var.environment

    tier        = "data"

    role        = "cache"

  }



  network {

    network_id = var.network_id

  }



  firewall_ids = var.firewall_ids

}



resource "hcloud_volume" "redis_data" {

  name      = "${var.environment}-redis-data"

  size      = 20

  server_id = hcloud_server.cache.id

  automount = true

  format    = "ext4"



  labels = {

    environment = var.environment

    role        = "cache"

    encrypted   = "true"

  }

}

