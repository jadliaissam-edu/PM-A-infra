variable "environment" {
  type = string
}
variable "network_id" {
  type = string
}
variable "ssh_public_key" {
  type = string
}
variable "location" {
  type    = string
  default = "hel1"
}

variable "server_type" {
  type    = string
  default = "cpx22"
}
variable "db_password" {
  type      = string
  sensitive = true
}