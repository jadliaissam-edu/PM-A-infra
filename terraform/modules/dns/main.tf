terraform {
  required_providers {
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = ">= 1.2.0"
    }
  }
}

# Hetzner DNS zone must already exist (created via Hetzner DNS console)
# HETZNER_DNS_API_TOKEN environment variable is required

data "hetznerdns_zone" "main" {
  name = var.domain
}

# ── A Records ──────────────────────────────────────────────
resource "hetznerdns_record" "app" {
  zone_id = data.hetznerdns_zone.main.id
  name    = var.environment == "production" ? "@" : var.environment
  value   = var.app_ip
  type    = "A"
  ttl     = 300
}

resource "hetznerdns_record" "api" {
  zone_id = data.hetznerdns_zone.main.id
  name    = var.environment == "production" ? "api" : "api-${var.environment}"
  value   = var.app_ip
  type    = "A"
  ttl     = 300
}

resource "hetznerdns_record" "ai" {
  zone_id = data.hetznerdns_zone.main.id
  name    = var.environment == "production" ? "ai" : "ai-${var.environment}"
  value   = var.app_ip
  type    = "A"
  ttl     = 300
}

# ── CAA Record (Let's Encrypt) ─────────────────────────────
resource "hetznerdns_record" "caa" {
  zone_id = data.hetznerdns_zone.main.id
  name    = var.environment == "production" ? "@" : var.environment
  value   = "0 issue \"letsencrypt.org\""
  type    = "CAA"
  ttl     = 300
}
