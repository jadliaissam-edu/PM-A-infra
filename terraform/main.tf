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



variable "environment" {

  description = "Deployment environment (e.g., dev, staging, production)"

  type        = string

  default     = "dev"

}



variable "domain" {

  description = "Base domain name for the application"

  type        = string

  default     = "agileflow.local"

}



variable "ssh_public_key_path" {

  description = "Path to the SSH public key for server access"

  type        = string

  default     = "~/.ssh/id_ed25519.pub"

}



variable "ssh_key_name" {

  description = "Name of the existing SSH key in Hetzner Cloud"

  type        = string

  default     = "deploy-key"

}



variable "location" {

  description = "Hetzner datacenter location"

  type        = string

  default     = "hel1"

}



variable "server_count" {

  description = "Number of application servers"

  type        = number

  default     = 1

}



variable "db_password" {

  description = "PostgreSQL password"

  type        = string

  sensitive   = true

  default     = "AgileFlow2024!"

}



provider "hcloud" {

  # Token is read from the environment by the provider (HCLOUD_TOKEN)

}



locals {

  ssh_public_key = data.hcloud_ssh_key.deploy.public_key

}



# ── SSH Key (use existing key in Hetzner Cloud) ──────────

data "hcloud_ssh_key" "deploy" {

  name = var.ssh_key_name

}



# ── Network ──────────────────────────────────────────────

module "network" {

  source      = "./modules/network"

  environment = var.environment

}



# ── Compute (App servers) ────────────────────────────────

module "compute" {

  source          = "./modules/compute"

  environment     = var.environment

  server_count    = var.server_count

  network_id      = module.network.network_id

  location        = var.location

  ssh_public_key  = local.ssh_public_key

  ssh_key_id      = data.hcloud_ssh_key.deploy.id

  firewall_ids    = [module.network.firewall_id]

}



# ── Database (PostgreSQL) ────────────────────────────────

module "database" {

  source         = "./modules/database"

  environment    = var.environment

  network_id     = module.network.network_id

  location       = var.location

  db_password    = var.db_password

  ssh_public_key = local.ssh_public_key

  ssh_key_id     = data.hcloud_ssh_key.deploy.id

  firewall_ids   = [module.network.firewall_id]

}



# ── Cache (Redis) ────────────────────────────────────────

module "cache" {

  source         = "./modules/cache"

  environment    = var.environment

  network_id     = module.network.network_id

  location       = var.location

  ssh_public_key = local.ssh_public_key

  ssh_key_id     = data.hcloud_ssh_key.deploy.id

  firewall_ids   = [module.network.firewall_id]

}



# ── Storage (S3-compatible volumes) ──────────────────────

module "storage" {

  source      = "./modules/storage"

  environment = var.environment

  location    = var.location

}



# ── DNS ──────────────────────────────────────────────────

# TODO: Enable when Hetzner DNS API token is available

# Requires: HETZNER_DNS_API_TOKEN env var or hetzner_dns_api_token variable

# module "dns" {

#   source      = "./modules/dns"

#   environment = var.environment

#   domain      = var.domain

#   app_ip      = module.compute.instance_ips[0]

# }



# ── SSL (Let's Encrypt via ACME) ─────────────────────────

# TODO: Enable when Hetzner DNS API token is available

# Requires: HETZNER_DNS_API_TOKEN for DNS-01 challenge

# module "ssl" {

#   source                = "./modules/ssl"

#   environment           = var.environment

#   domain                = var.domain

#   san_domains           = var.environment == "production" ? ["api.${var.domain}", "ai.${var.domain}"] : []

#   hetzner_dns_api_token = var.hetzner_dns_api_token

# }



# ── Outputs ──────────────────────────────────────────────

output "server_ips" {

  description = "IP addresses of the application servers"

  value       = module.compute.instance_ips

}



output "database_ip" {

  description = "Private IP of the PostgreSQL server"

  value       = module.database.db_private_ip

}



output "database_public_ip" {

  description = "Public IP of the PostgreSQL server"

  value       = module.database.db_server_ip

}



output "cache_ip" {

  description = "Private IP of the Redis server"

  value       = module.cache.cache_private_ip

}



output "cache_public_ip" {

  description = "Public IP of the Redis server"

  value       = module.cache.cache_server_ip

}



output "network_id" {

  description = "ID of the Hetzner private network"

  value       = module.network.network_id

}



output "firewall_id" {

  description = "ID of the Hetzner firewall"

  value       = module.network.firewall_id

}



output "ssh_key_id" {

  description = "ID of the SSH key in Hetzner"

  value       = data.hcloud_ssh_key.deploy.id

}