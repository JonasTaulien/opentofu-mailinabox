variable "digital_ocean_ssh_key_pub_file_path" {
  type = string
}

variable "miab_droplet_region" {
  type = string
}

variable "miab_droplet_size" {
  type = string
}

variable "miab_first_admin_user_name" {
  type        = string
  description = "e.g. admin. Will be prepended to miab_domain to form the initial email address"
}

variable "miab_first_admin_user_password" {
  type        = string
  description = "Will be used as password for the first admin user to overwrite the default initial password"
}

locals {
  miab_box_name                       = "box.${var.miab_domain}"
  miab_first_admin_user_email_address = "${var.miab_first_admin_user_name}@${var.miab_domain}"
}

resource "digitalocean_ssh_key" "ssh_key" {
  name       = "Mail In A Box Terraform SSH Key"
  public_key = file(var.digital_ocean_ssh_key_pub_file_path)
}

resource "digitalocean_droplet" "miab_server" {
  // newer versions: "ubuntu-23-04-x64"
  image      = "ubuntu-22-04-x64"
  name       = local.miab_box_name
  region     = var.miab_droplet_region
  size       = var.miab_droplet_size
  backups    = true
  monitoring = true
  ssh_keys   = [digitalocean_ssh_key.ssh_key.fingerprint]
  user_data  = templatefile(
    "miab-cloud.cfg.tftpl",
    {
      TERRAFORM_TEMPLATE_BOX_PRIMARY_HOSTNAME = local.miab_box_name
      TERRAFORM_TEMPLATE_FIRST_EMAIL_ADDRESS  = local.miab_first_admin_user_email_address
      TERRAFORM_TEMPLATE_FIRST_EMAIL_PASSWORD = var.miab_first_admin_user_password
    }
  )
}

resource "digitalocean_project" "miab_project" {
  name        = "Mail In A Box"
  purpose     = "Mail Server"
  environment = "Production"
  resources   = [
    digitalocean_droplet.miab_server.urn
  ]
}

output "miab_droplet_ssh_instructions" {
  value       = "ssh root@${digitalocean_droplet.miab_server.ipv4_address}"
  description = "SSH into the created droplet (you have to wait ~15s before this will work)"
}

output "miab_first_admin_user_email_address" {
  value = local.miab_first_admin_user_email_address
}

output "miab_first_admin_user_password" {
  value = var.miab_first_admin_user_password
  sensitive = true
}

output "miab_login" {
  value = "https://${digitalocean_droplet.miab_server.ipv4_address}/admin"
}

output "miab_copy_backup_file_command" {
  value = "scp root@${digitalocean_droplet.miab_server.ipv4_address}:/home/user-data/backup/secret_key.txt /directory/on/your/computer"
}

output "miab_nameservers" {
  value = [
    "ns1.${local.miab_box_name}",
    "ns2.${local.miab_box_name}"
  ]
}
