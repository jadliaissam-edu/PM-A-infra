terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = ">= 2.0.0"
    }
  }
}

# ACME client for Let's Encrypt
# ACME_EMAIL and HETZNER_DNS_API_TOKEN env vars required

resource "acme_certificate" "main" {
  account_key_pem = tls_private_key.acme_key.private_key_pem
  common_name     = var.domain

  dns_challenge {
    provider = "hetzner"

    config = {
      HETZNER_API_KEY = var.hetzner_dns_api_token
    }
  }

  # Subject Alternative Names
  subject_alternative_names = var.san_domains

  # Renew 30 days before expiry
  min_days_remaining = 30
}

resource "tls_private_key" "acme_key" {
  algorithm = "ECDSA"
  ecdsa_curve = "P256"
}
