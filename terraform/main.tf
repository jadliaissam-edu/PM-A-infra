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

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for server access"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
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
  default     = "secret"
}

provider "hcloud" {
  # Token is read from the environment by the provider (HCLOUD_TOKEN)
}

locals {
  ssh_public_key = trimspace(file(var.ssh_public_key_path))
}

# ── Network ──────────────────────────────────────────────
module "network" {
  source      = "./modules/network"
  environment = var.environment
}

# ── Compute (App servers) ────────────────────────────────
module "compute" {
  source       = "./modules/compute"
  environment  = var.environment
  server_count = var.server_count
  network_id   = module.network.network_id
  location     = var.location
  ssh_public_key = local.ssh_public_key
}

# ── Database (PostgreSQL) ────────────────────────────────
module "database" {
  source      = "./modules/database"
  environment = var.environment
  network_id  = module.network.network_id
  location    = var.location
  db_password = var.db_password
  ssh_public_key = local.ssh_public_key
}

# ── Cache (Redis) ────────────────────────────────────────
module "cache" {
  source      = "./modules/cache"
  environment = var.environment
  network_id  = module.network.network_id
  location    = var.location
  ssh_public_key = local.ssh_public_key
}

# ── Storage (S3-compatible volumes) ──────────────────────
module "storage" {
  source      = "./modules/storage"
  environment = var.environment
}

# ── DNS ──────────────────────────────────────────────────
module "dns" {
  source      = "./modules/dns"
  environment = var.environment
}

# ── SSL ──────────────────────────────────────────────────
module "ssl" {
  source      = "./modules/ssl"
  environment = var.environment
}

# ── Outputs ──────────────────────────────────────────────
output "server_ips" {
  description = "IP addresses of the application servers"
  value       = module.compute.instance_ips
}

output "database_ip" {
  description = "Private IP of the PostgreSQL server"
  value       = module.database.db_server_ip
}

output "cache_ip" {
  description = "Private IP of the Redis server"
  value       = module.cache.cache_server_ip
}

output "network_id" {
  description = "ID of the Hetzner private network"
  value       = module.network.network_id
}