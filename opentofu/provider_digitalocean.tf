variable "digital_ocean_token" {
  type = string
  sensitive = true
}

provider "digitalocean" {
  token = var.digital_ocean_token
}
