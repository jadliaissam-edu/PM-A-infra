variable "environment" {
  type = string
}
variable "network_id" {
  type = string
}
variable "ssh_public_key" {
  type = string
}
variable "ssh_key_id" {
  type = string
}
variable "firewall_ids" {
  type    = list(string)
  default = []
}
variable "location" {
  type    = string
  default = "hel1"
}

variable "server_type" {
  type    = string
  default = "cpx22"
}