variable "environment" { type = string default = "staging" }
variable "location" { type = string default = "hel1" }
variable "server_count" { type = number default = 2 }
variable "ssh_public_key_path" { type = string default = "~/.ssh/id_ed25519.pub" }
variable "ssh_key_name" { type = string default = "deploy-key" }
variable "db_password" { type = string sensitive = true default = "AgileFlow2024!" }
variable "domain" { type = string default = "staging.agileflow.local" }