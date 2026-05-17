variable "environment" {
  type = string
}
variable "domain" {
  type    = string
  default = "agileflow.local"
}
variable "san_domains" {
  type    = list(string)
  default = []
}
variable "hetzner_dns_api_token" {
  type      = string
  sensitive = true
}

output "certificate_pem" {
  value     = acme_certificate.main.certificate_pem
  sensitive = true
}
output "private_key_pem" {
  value     = acme_certificate.main.private_key_pem
  sensitive = true
}
output "issuer_pem" {
  value     = acme_certificate.main.issuer_pem
  sensitive = true
}