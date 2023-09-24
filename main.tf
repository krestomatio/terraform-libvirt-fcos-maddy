module "maddy" {
  source  = "krestomatio/fcos/libvirt"
  version = "0.0.24"

  # custom
  butane_snippets_additional = compact(
    concat(
      [
        try(module.butane_snippet_install_certbot[0].config, ""),
        data.template_file.butane_snippet_install_maddy.rendered
      ],
      var.butane_snippets_additional
    )
  )

  # butane common
  fqdn                = var.fqdn
  cidr_ip_address     = var.cidr_ip_address
  mac                 = var.mac
  ssh_authorized_key  = var.ssh_authorized_key
  nameservers         = var.nameservers
  timezone            = var.timezone
  rollout_wariness    = var.rollout_wariness
  periodic_updates    = var.periodic_updates
  keymap              = var.keymap
  autostart           = var.autostart
  etc_hosts_extra     = var.etc_hosts_extra
  interface_name      = var.interface_name
  sync_time_with_host = var.sync_time_with_host
  # libvirt
  vcpu                  = var.vcpu
  memory                = var.memory
  machine               = var.machine
  root_base_volume_name = var.root_base_volume_name
  root_base_volume_pool = var.root_base_volume_pool
  data_volume_pool      = var.data_volume_pool
  data_volume_size      = var.data_volume_size
  data_volume_path      = local.data_volume_path
  backup_volume_pool    = var.backup_volume_pool
  ignition_pool         = var.ignition_pool
  network_bridge        = var.network_bridge
  network_name          = var.network_name
  network_id            = var.network_id
}
