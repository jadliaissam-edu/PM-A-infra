terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

module "network" {
  source = "./modules/network"
  environment = var.environment
}

module "compute" {
  source = "./modules/compute"
  environment = var.environment
  server_count = var.server_count
}