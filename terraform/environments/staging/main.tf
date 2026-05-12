terraform {

  required_providers {

    hcloud = {

      source  = "hetznercloud/hcloud"

      version = ">= 1.45.0"

    }

    tls = {

      source  = "hashicorp/tls"

      version = ">= 4.0.0"

    }

  }

  backend "local" {

    path = "terraform.tfstate"

  }

}



provider "hcloud" {

  # Token read from HCLOUD_TOKEN env var

}



locals {

  ssh_public_key = trimspace(file(var.ssh_public_key_path))

}



data "hcloud_ssh_key" "deploy" {

  name = var.ssh_key_name

}



module "network" {

  source      = "../../modules/network"

  environment = var.environment

}



module "compute" {

  source          = "../../modules/compute"

  environment     = var.environment

  server_count    = var.server_count

  network_id      = module.network.network_id

  location        = var.location

  ssh_public_key  = local.ssh_public_key

  ssh_key_id      = hcloud_ssh_key.deploy.id

  firewall_ids    = [module.network.firewall_id]

}



module "database" {

  source         = "../../modules/database"

  environment    = var.environment

  network_id     = module.network.network_id

  location       = var.location

  db_password    = var.db_password

  ssh_public_key = local.ssh_public_key

  ssh_key_id     = hcloud_ssh_key.deploy.id

  firewall_ids   = [module.network.firewall_id]

}



module "cache" {

  source         = "../../modules/cache"

  environment    = var.environment

  network_id     = module.network.network_id

  location       = var.location

  ssh_public_key = local.ssh_public_key

  ssh_key_id     = hcloud_ssh_key.deploy.id

  firewall_ids   = [module.network.firewall_id]

}



module "storage" {

  source      = "../../modules/storage"

  environment = var.environment

  location    = var.location

}



# TODO: Enable when Hetzner DNS API token is available

# module "dns" {

#   source      = "../../modules/dns"

#   environment = var.environment

#   domain      = var.domain

#   app_ip      = module.compute.instance_ips[0]

# }

#

# module "ssl" {

#   source                = "../../modules/ssl"

#   environment           = var.environment

#   domain                = var.domain

#   san_domains           = ["api.${var.domain}", "ai.${var.domain}"]

#   hetzner_dns_api_token = var.hetzner_dns_api_token

# }



output "server_ips" {

  value = module.compute.instance_ips

}



output "database_ip" {

  value = module.database.db_private_ip

}



output "cache_ip" {

  value = module.cache.cache_private_ip

}



output "firewall_id" {

  value = module.network.firewall_id

}

