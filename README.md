# OpenTofu for Mail In A Box
This repository contains the needed "infrastructure as code" to set up a [Mail-in-a-Box](https://mailinabox.email/).
If you follow these instructions, it will

1. Create a Digital Ocean Droplet as virtual machine for the Mail-In-A-Box
2. Create a S3 Bucket for storing the Backups
3. Install Mail-In-A-Box on the Droplet

After following teh instructions, you have your own mailserver and cloud :)

## Instructions
1. Initialize opentofu by running `tofu init`
2. Add `terraform.tfvars` and set required variables (this file gets git-ignored, so you do not accidentally commit
   secrets)
3. Execute `tofu plan` and check if you agree what it wants to do
4. Execute `tofu apply` to set everything up
5. Wait 15 seconds and use the output of `tofu output miab_droplet_ssh_instructions` to `ssh` into the droplet
6. Execute `tail -f /var/log/cloud-init-output.log` inside of the droplet and watch the output.
   * If the mailinabox installation fails because the ip-address is on a spam list
     1. destroy the droplet again by executing `tofu destroy -target digitalocean_droplet.miab_server` on your machine
     2. Re-execute `tofu plan` and `tofu apply` so that the droplet gets recreated, and you get a new ip-address
     3. Re-watch the logs and repeat until the mailinabox setup was able to complete
7. Log into the box by using the URL that you get when executing `tofu output miab_login`
    * E-Mail: Execute `tofu output miab_first_admin_user_email_address` to get the value
    * Password: Execute `tofu output miab_first_admin_user_password` to get the value
8. Configure the backup to the created S3 bucket by setting the following values in the form at `System > Backup Status`
    * Backup to: `S3`
    * S3 Region: Execute `tofu output backup_s3_bucket_region` to get the value
    * S3 Host: Execute `tofu output backup_s3_bucket_host` to get the value
    * S3 Region Name: Leave empty
    * S3 Bucket & Path: Execute `tofu output backup_s3_bucket_path` to get the value (remove the `/` at the end)
    * S3 Access Key: Execute `tofu output backup_s3_bucket_access-key` to get the value
    * S3 Secret Access Key: Execute `tofu output backup_s3_bucket_secret-key` to get the value
    * Retention Days: Set this value as you wish to
9. Execute first backup by executing `sudo /mailinabox/management/backup.py` inside of the droplet
10. Copy the file `/home/user-data/backup/secret_key.txt` from the machine to a secure location by executing the
    command `tofu output miab_copy_backup_file_command` to get the `scp` command you have to execute. Execute that
    command.
11. Set the Nameservers of your domain to the domains you get when you execute `tofu output backup_s3_bucket_path`
12. Again, log into the admin panel of your box by using the URL from the `tofu output miab_login` command. Check the
    status of your box by navigating to `System > Status Checks`

## TODO
* Automatically set Backup to S3
* Let user configure timezone and locale in `tfvars`
* Set correct text encoding, so that they are no issues with `f�r` or `zus�tzliche`


## Source used for setting this up
* [MiaB Maintenance Guide](https://mailinabox.email/maintenance.html#upgrade)
* [OpenTofu documentation](https://opentofu.org/docs/)
* [Terraform Provider Registry](https://registry.terraform.io/browse/providers)
* [DigitalOcean Provider Documentation](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)
* [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [cloud-init Documentation](https://cloudinit.readthedocs.io/en/latest/howto/locate_files.html)


