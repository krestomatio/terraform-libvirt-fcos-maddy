Terraform module for creating a [Maddy mail server](https://maddy.email/) using [Fedora CoreOS](https://docs.fedoraproject.org/en-US/fedora-coreos/), and [Libvirt](https://libvirt.org/).

## Dependencies
The following are the dependencies to create the VM with this module:
* [libvirt](https://libvirt.org/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_ct"></a> [ct](#requirement\_ct) | 0.11.0 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | ~> 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_butane_snippet_install_certbot"></a> [butane\_snippet\_install\_certbot](#module\_butane\_snippet\_install\_certbot) | krestomatio/butane-snippets/ct//modules/certbot | 0.0.12 |
| <a name="module_maddy"></a> [maddy](#module\_maddy) | krestomatio/fcos/libvirt | 0.0.24 |

## Resources

| Name | Type |
|------|------|
| [template_file.butane_snippet_install_maddy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_rpms"></a> [additional\_rpms](#input\_additional\_rpms) | Additional rpms to install during boot using rpm-ostree, along with any pre or post command | <pre>object(<br>    {<br>      cmd_pre  = optional(list(string), [])<br>      list     = optional(list(string), [])<br>      cmd_post = optional(list(string), [])<br>    }<br>  )</pre> | <pre>{<br>  "cmd_post": [],<br>  "cmd_pre": [],<br>  "list": []<br>}</pre> | no |
| <a name="input_autostart"></a> [autostart](#input\_autostart) | Autostart with libvirt host | `bool` | `null` | no |
| <a name="input_backup_volume_pool"></a> [backup\_volume\_pool](#input\_backup\_volume\_pool) | Node default backup volume pool | `string` | `null` | no |
| <a name="input_backup_volume_size"></a> [backup\_volume\_size](#input\_backup\_volume\_size) | Node default backup volume size in bytes | `number` | `null` | no |
| <a name="input_butane_snippets_additional"></a> [butane\_snippets\_additional](#input\_butane\_snippets\_additional) | Additional butane snippets | `list(string)` | `[]` | no |
| <a name="input_certbot"></a> [certbot](#input\_certbot) | Certbot config | <pre>object(<br>    {<br>      agree_tos    = bool<br>      staging      = optional(bool)<br>      email        = string<br>      http_01_port = optional(number)<br>    }<br>  )</pre> | `null` | no |
| <a name="input_cidr_ip_address"></a> [cidr\_ip\_address](#input\_cidr\_ip\_address) | CIDR IP Address. Ex: 192.168.1.101/24 | `string` | `null` | no |
| <a name="input_cpu_mode"></a> [cpu\_mode](#input\_cpu\_mode) | Libvirt default cpu mode for VMs | `string` | `null` | no |
| <a name="input_cpus_limit"></a> [cpus\_limit](#input\_cpus\_limit) | Number of CPUs to limit the container | `number` | `0` | no |
| <a name="input_data_volume_pool"></a> [data\_volume\_pool](#input\_data\_volume\_pool) | Node default data volume pool | `string` | `null` | no |
| <a name="input_data_volume_size"></a> [data\_volume\_size](#input\_data\_volume\_size) | Node default data volume size in bytes | `number` | `null` | no |
| <a name="input_etc_hosts"></a> [etc\_hosts](#input\_etc\_hosts) | /etc/host list | <pre>list(<br>    object(<br>      {<br>        ip       = string<br>        hostname = string<br>        fqdn     = string<br>      }<br>    )<br>  )</pre> | `null` | no |
| <a name="input_etc_hosts_extra"></a> [etc\_hosts\_extra](#input\_etc\_hosts\_extra) | /etc/host extra block | `string` | `null` | no |
| <a name="input_external_fqdn"></a> [external\_fqdn](#input\_external\_fqdn) | FQDN to access Maddy mail | `string` | n/a | yes |
| <a name="input_fqdn"></a> [fqdn](#input\_fqdn) | Node FQDN | `string` | n/a | yes |
| <a name="input_ignition_pool"></a> [ignition\_pool](#input\_ignition\_pool) | Default ignition files pool | `string` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | Maddy mail container image | <pre>object(<br>    {<br>      name    = optional(string, "docker.io/foxcpp/maddy")<br>      version = optional(string, "latest")<br>    }<br>  )</pre> | <pre>{<br>  "name": "docker.io/maddylabs/mail-server",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_keymap"></a> [keymap](#input\_keymap) | Keymap | `string` | `null` | no |
| <a name="input_log_volume_pool"></a> [log\_volume\_pool](#input\_log\_volume\_pool) | Node default log volume pool | `string` | `null` | no |
| <a name="input_log_volume_size"></a> [log\_volume\_size](#input\_log\_volume\_size) | Node default log volume size in bytes | `number` | `null` | no |
| <a name="input_mac"></a> [mac](#input\_mac) | Mac address | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Node default memory in MiB | `number` | `512` | no |
| <a name="input_memory_limit"></a> [memory\_limit](#input\_memory\_limit) | Amount of memory to limit the container | `string` | `""` | no |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | List of nameservers for VMs | `list(string)` | `null` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Libvirt default network bridge name for VMs | `string` | `null` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Libvirt default network id for VMs | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Libvirt default network name for VMs | `string` | `null` | no |
| <a name="input_periodic_updates"></a> [periodic\_updates](#input\_periodic\_updates) | Only reboot for updates during certain timeframes<br>{<br>  time\_zone = "localtime"<br>  windows = [<br>    {<br>      days           = ["Sat"],<br>      start\_time     = "23:30",<br>      length\_minutes = "60"<br>    },<br>    {<br>      days           = ["Sun"],<br>      start\_time     = "00:30",<br>      length\_minutes = "60"<br>    }<br>  ]<br>} | <pre>object(<br>    {<br>      time_zone = optional(string, "")<br>      windows = list(<br>        object(<br>          {<br>            days           = list(string)<br>            start_time     = string<br>            length_minutes = string<br>          }<br>        )<br>      )<br>    }<br>  )</pre> | `null` | no |
| <a name="input_primary_domain"></a> [primary\_domain](#input\_primary\_domain) | Primary domain for Maddy mail | `string` | n/a | yes |
| <a name="input_rollout_wariness"></a> [rollout\_wariness](#input\_rollout\_wariness) | Wariness to update, 1.0 (very cautious) to 0.0 (very eager) | `string` | `null` | no |
| <a name="input_root_base_volume_name"></a> [root\_base\_volume\_name](#input\_root\_base\_volume\_name) | Node default base root volume name | `string` | n/a | yes |
| <a name="input_root_base_volume_pool"></a> [root\_base\_volume\_pool](#input\_root\_base\_volume\_pool) | Node default base root volume pool | `string` | `null` | no |
| <a name="input_root_volume_pool"></a> [root\_volume\_pool](#input\_root\_volume\_pool) | Node default root volume pool | `string` | `null` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Node default root volume size in bytes | `number` | `null` | no |
| <a name="input_ssh_authorized_key"></a> [ssh\_authorized\_key](#input\_ssh\_authorized\_key) | Authorized ssh key for core user | `string` | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for VMs as listed by `timedatectl list-timezones` | `string` | `null` | no |
| <a name="input_vcpu"></a> [vcpu](#input\_vcpu) | Node default vcpu count | `number` | `null` | no |
| <a name="input_wait_for_lease"></a> [wait\_for\_lease](#input\_wait\_for\_lease) | Wait for network lease | `bool` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->