# Mail In A Box
## TODO
* Upload old backup and see if everything works
* Set Backup to S3
* Function to import old backup from S3

## Initialize
```sh
tofu init
```

## Destroy droplet in case its on a spam list
```sh
tofu destroy -target digitalocean_droplet.miab_server
```

## Source used for setting this up
* [OpenTofu documentation](https://opentofu.org/docs/)
* [Terraform Provider Registry](https://registry.terraform.io/browse/providers)
* [DigitalOcean Provider Documentation](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)
* [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Access Cloud-Init Logs:
See [cloud-init Documentation](https://cloudinit.readthedocs.io/en/latest/howto/locate_files.html)
* Execute `tail -f /var/log/cloud-init-output.log` inside of the box
