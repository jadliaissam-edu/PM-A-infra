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

# ── Network ──────────────────────────────────────────────
module "network" {
  source      = "../../modules/network"
  environment = var.environment
}

# ── Compute: 3 app servers for HA ────────────────────────
module "compute" {
  source       = "../../modules/compute"
  environment  = var.environment
  server_count = var.server_count
  network_id   = module.network.network_id
  location     = var.location
  server_type  = "cpx32"
  ssh_public_key = local.ssh_public_key
}

# ── Database: dedicated data node ────────────────────────
module "database" {
  source      = "../../modules/database"
  environment = var.environment
  network_id  = module.network.network_id
  location    = var.location
  db_password = var.db_password
  ssh_public_key = local.ssh_public_key
}

# ── Cache: dedicated data node ──────────────────────────
module "cache" {
  source      = "../../modules/cache"
  environment = var.environment
  network_id  = module.network.network_id
  location    = var.location
  ssh_public_key = local.ssh_public_key
}

# ── Storage ──────────────────────────────────────────────
module "storage" {
  source      = "../../modules/storage"
  environment = var.environment
  location    = var.location
}

# ── DNS ──────────────────────────────────────────────────
module "dns" {
  source      = "../../modules/dns"
  environment = var.environment
}

# ── SSL ──────────────────────────────────────────────────
module "ssl" {
  source      = "../../modules/ssl"
  environment = var.environment
}

# ── Outputs ──────────────────────────────────────────────
output "server_ips" {
  value = module.compute.instance_ips
}

output "database_ip" {
  value = module.database.db_server_ip
}

output "cache_ip" {
  value = module.cache.cache_server_ip
}
