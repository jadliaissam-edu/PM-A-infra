terraform {

  required_providers {

    hcloud = {

      source = "hetznercloud/hcloud"

    }

  }

}



resource "hcloud_network" "vpc" {

  name     = "${var.environment}-network"

  ip_range = "10.0.0.0/16"

  labels = {

    environment = var.environment

  }

}



resource "hcloud_network_subnet" "app_subnet" {

  network_id   = hcloud_network.vpc.id

  ip_range     = "10.0.1.0/24"

  network_zone = "eu-central"

  type         = "cloud"

}



resource "hcloud_network_subnet" "data_subnet" {

  network_id   = hcloud_network.vpc.id

  ip_range     = "10.0.2.0/24"

  network_zone = "eu-central"

  type         = "cloud"

}



# ── Firewall: only ports 80, 443 and SSH (2222) per security spec ──

resource "hcloud_firewall" "main" {

  name = "${var.environment}-firewall"



  rule {

    direction  = "in"

    protocol   = "tcp"

    port       = "80"

    source_ips = ["0.0.0.0/0", "::/0"]

  }



  rule {

    direction  = "in"

    protocol   = "tcp"

    port       = "443"

    source_ips = ["0.0.0.0/0", "::/0"]

  }



  rule {

    direction  = "in"

    protocol   = "tcp"

    port       = "22"

    source_ips = ["0.0.0.0/0", "::/0"]

  }



  rule {

    direction  = "in"

    protocol   = "tcp"

    port       = "2222"

    source_ips = ["0.0.0.0/0", "::/0"]

  }



  # Allow all outbound traffic

  rule {

    direction = "out"

    protocol  = "tcp"

    port      = "any"

    destination_ips = ["0.0.0.0/0", "::/0"]

  }



  rule {

    direction = "out"

    protocol  = "udp"

    port      = "any"

    destination_ips = ["0.0.0.0/0", "::/0"]

  }



  # Allow ICMP (ping) for monitoring

  rule {

    direction  = "in"

    protocol   = "icmp"

    source_ips = ["10.0.0.0/16"]

  }



  labels = {

    environment = var.environment

  }

}