######################### values #########################
locals {
  #### module ####
  # certbot
  certbot = null
  # certbot = {
  #   staging      = true
  #   agree_tos    = true
  #   http_01_port = 8888
  #   email        = "info@example.com"
  # }

  # maddy
  cpus_limit     = 0.7
  memory_limit   = "700m"
  external_fqdn  = "maddy.example.com"
  primary_domain = "example.com"

  # libvirt
  fqdn               = local.external_fqdn
  cidr_ip_address    = "10.10.17.11/24"
  mac                = "50:50:10:10:17:11"
  vcpu               = 1
  memory             = 1024
  root_volume_size   = 1024 * 1024 * 1024 * 10 # in bytes, 10 Gi
  log_volume_size    = 1024 * 1024 * 1024 * 5  # in bytes, 5 Gi
  data_volume_size   = 1024 * 1024 * 1024 * 10 # in bytes, 10 Gi
  backup_volume_size = 1024 * 1024 * 1024 * 10 # in bytes, 10 Gi
  ssh_authorized_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  nameservers        = ["8.8.8.8"]
  timezone           = "America/Costa_Rica"
  keymap             = "latam"
  rollout_wariness   = "0.5"
  additional_rpms = {
    list = ["nano"]
  }
  periodic_updates = {
    time_zone = "localtime"
    windows = [
      {
        days           = ["Sat"],
        start_time     = "23:30",
        length_minutes = "60"
      },
      {
        days           = ["Sun"],
        start_time     = "00:30",
        length_minutes = "60"
      }
    ]
  }
  etc_hosts = [
    {
      ip       = "127.0.0.1"
      hostname = "maddy-01"
      fqdn     = "maddy-01.example.com"
    },
    {
      ip       = "192.168.0.10"
      hostname = "other-server-01"
      fqdn     = "other-server-01.example.com"
    }
  ]
  #### end module values ####

  # others
  prefix = "maddy"

  # network
  net_name      = "libvirt-fcos-${local.prefix}"
  net_cidr_ipv4 = "10.10.17.0/24"
  net_cidr_ipv6 = "2001:db8:ca2:17::/64"

  # image
  image_name           = "terraform-libvirt-fcos-${local.fcos_image_name}"
  fcos_image_version   = "38.20230722.3.0"
  fcos_image_arch      = "x86_64"
  fcos_image_stream    = "stable"
  fcos_image_sha256sum = "ecb3bf1fc4da70fc99fb25706820aed9d3f46259ecee65ffd7e805569729e2b3"
  fcos_image_url       = "https://builds.coreos.fedoraproject.org/prod/streams/${local.fcos_image_stream}/builds/${local.fcos_image_version}/${local.fcos_image_arch}/fedora-coreos-${local.fcos_image_version}-qemu.${local.fcos_image_arch}.qcow2.xz"
  fcos_image_name      = "fcos-${local.fcos_image_stream}-${local.fcos_image_version}-${local.fcos_image_arch}.qcow2"
}

# network
resource "libvirt_network" "libvirt_fcos_base" {
  name      = local.net_name
  mode      = "nat"
  domain    = "cluster.local"
  addresses = [local.net_cidr_ipv4, local.net_cidr_ipv6]
}

# image
resource "null_resource" "fcos_image_download" {
  provisioner "local-exec" {
    command = <<-TEMPLATE
      pushd /tmp
      if [ ! -f "${local.fcos_image_name}" ]; then
        curl -L "${local.fcos_image_url}" -o "${local.fcos_image_name}.xz"
        echo "${local.fcos_image_sha256sum} ${local.fcos_image_name}.xz" | sha256sum -c
        unxz "${local.fcos_image_name}.xz"
      fi
      popd
    TEMPLATE
  }
}

resource "libvirt_volume" "fcos_image" {
  depends_on = [null_resource.fcos_image_download]

  name   = local.image_name
  source = "/tmp/${local.fcos_image_name}"
}

######################## module #########################
module "libvirt_fcos_maddy" {
  depends_on = [libvirt_volume.fcos_image]

  source = "../.."

  # certbot
  certbot = local.certbot
  # maddy
  cpus_limit     = local.cpus_limit
  memory_limit   = local.memory_limit
  external_fqdn  = local.external_fqdn
  primary_domain = local.primary_domain
  # libvirt
  fqdn               = local.fqdn
  cidr_ip_address    = local.cidr_ip_address
  mac                = local.mac
  ssh_authorized_key = local.ssh_authorized_key
  nameservers        = local.nameservers
  timezone           = local.timezone
  rollout_wariness   = local.rollout_wariness
  periodic_updates   = local.periodic_updates
  keymap             = local.keymap
  etc_hosts          = local.etc_hosts
  additional_rpms    = local.additional_rpms
  vcpu               = local.vcpu
  memory             = local.memory
  root_volume_size   = local.root_volume_size
  log_volume_size    = local.log_volume_size
  data_volume_size   = local.data_volume_size
  backup_volume_size = local.backup_volume_size

  root_base_volume_name = libvirt_volume.fcos_image.name
  network_id            = libvirt_network.libvirt_fcos_base.id
}
