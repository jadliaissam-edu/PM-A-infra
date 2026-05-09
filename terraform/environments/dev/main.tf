terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

locals {
  ssh_public_key = trimspace(file(var.ssh_public_key_path))
}

module "network" {
  source      = "../../modules/network"
  environment = var.environment
}

module "compute" {
  source       = "../../modules/compute"
  environment  = var.environment
  server_count = var.server_count
  network_id   = module.network.network_id
  location     = var.location
  ssh_public_key = local.ssh_public_key
}

module "database" {
  source      = "../../modules/database"
  environment = var.environment
  network_id  = module.network.network_id
  location    = var.location
  db_password = var.db_password
  ssh_public_key = local.ssh_public_key
}

module "cache" {
  source      = "../../modules/cache"
  environment = var.environment
  network_id  = module.network.network_id
  location    = var.location
  ssh_public_key = local.ssh_public_key
}

module "storage" {
  source      = "../../modules/storage"
  environment = var.environment
  location    = var.location
}

output "server_ips" {
  value = module.compute.instance_ips
}