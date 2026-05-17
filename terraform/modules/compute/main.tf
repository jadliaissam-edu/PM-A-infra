terraform {

  required_providers {

    hcloud = {

      source = "hetznercloud/hcloud"

    }

  }

}



resource "hcloud_server" "app" {

  count = var.server_count



  name        = "${var.environment}-app-${count.index + 1}"

  server_type = var.server_type

  image       = var.image

  location    = var.location

  ssh_keys    = [var.ssh_key_id]



  labels = {

    environment = var.environment

    tier        = "app"

  }



  network {

    network_id = var.network_id

  }



  firewall_ids = var.firewall_ids

}