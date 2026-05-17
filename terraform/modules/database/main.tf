terraform {

  required_providers {

    hcloud = {

      source = "hetznercloud/hcloud"

    }

  }

}



resource "hcloud_server" "db" {

  name        = "${var.environment}-postgres"

  server_type = var.server_type

  image       = "ubuntu-22.04"

  location    = var.location

  ssh_keys    = [var.ssh_key_id]



  labels = {

    environment = var.environment

    tier        = "data"

    role        = "database"

  }



  network {

    network_id = var.network_id

  }



  firewall_ids = var.firewall_ids

}



resource "hcloud_volume" "db_data" {

  name      = "${var.environment}-db-data"

  size      = 50

  server_id = hcloud_server.db.id

  automount = true

  format    = "ext4"



  labels = {

    environment = var.environment

    role        = "database"

    encrypted   = "true"

  }

}

