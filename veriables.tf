# certbot
variable "certbot" {
  type = object(
    {
      agree_tos    = bool
      staging      = optional(bool)
      email        = string
      http_01_port = optional(number)
    }
  )
  description = "Certbot config"
  default     = null
}

# maddy mail
variable "image" {
  type = object(
    {
      name    = optional(string, "docker.io/foxcpp/maddy")
      version = optional(string, "latest")
    }
  )
  description = "Maddy mail container image"
  default = {
    name    = "docker.io/maddylabs/mail-server"
    version = "latest"
  }
  nullable = false
}

variable "external_fqdn" {
  type        = string
  description = "FQDN to access Maddy mail"
}

variable "primary_domain" {
  type        = string
  description = "Primary domain for Maddy mail"
}

variable "cpus_limit" {
  type        = number
  description = "Number of CPUs to limit the container"
  default     = 0
}

variable "memory_limit" {
  type        = string
  description = "Amount of memory to limit the container"
  default     = ""
  nullable    = false
}

# butane custom
variable "butane_snippets_additional" {
  type        = list(string)
  default     = []
  description = "Additional butane snippets"
  nullable    = false
}

# butane common
variable "ssh_authorized_key" {
  type        = string
  description = "Authorized ssh key for core user"
}

variable "nameservers" {
  type        = list(string)
  description = "List of nameservers for VMs"
  default     = null
}

variable "timezone" {
  type        = string
  description = "Timezone for VMs as listed by `timedatectl list-timezones`"
  default     = null
}

variable "rollout_wariness" {
  type        = string
  description = "Wariness to update, 1.0 (very cautious) to 0.0 (very eager)"
  default     = null
}

variable "periodic_updates" {
  type = object(
    {
      time_zone = optional(string, "")
      windows = list(
        object(
          {
            days           = list(string)
            start_time     = string
            length_minutes = string
          }
        )
      )
    }
  )
  description = <<-TEMPLATE
    Only reboot for updates during certain timeframes
    {
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
  TEMPLATE
  default     = null
}

variable "keymap" {
  type        = string
  description = "Keymap"
  default     = null
}

variable "etc_hosts" {
  type = list(
    object(
      {
        ip       = string
        hostname = string
        fqdn     = string
      }
    )
  )
  description = "/etc/host list"
  default     = null
}

variable "etc_hosts_extra" {
  type        = string
  description = "/etc/host extra block"
  default     = null
}

variable "additional_rpms" {
  type = object(
    {
      cmd_pre  = optional(list(string), [])
      list     = optional(list(string), [])
      cmd_post = optional(list(string), [])
    }
  )
  description = "Additional rpms to install during boot using rpm-ostree, along with any pre or post command"
  default = {
    cmd_pre  = []
    list     = []
    cmd_post = []
  }
  nullable = false
}

# libvirt node
variable "fqdn" {
  type        = string
  description = "Node FQDN"
}

variable "cidr_ip_address" {
  type        = string
  description = "CIDR IP Address. Ex: 192.168.1.101/24"
  validation {
    condition     = can(cidrhost(var.cidr_ip_address, 1))
    error_message = "Check cidr_ip_address format"
  }
  default = null
}

variable "mac" {
  type        = string
  description = "Mac address"
  default     = null
}

variable "cpu_mode" {
  type        = string
  description = "Libvirt default cpu mode for VMs"
  default     = null
}

variable "vcpu" {
  type        = number
  description = "Node default vcpu count"
  default     = null
}

variable "memory" {
  type        = number
  description = "Node default memory in MiB"
  default     = 512
  nullable    = false
}

variable "root_volume_pool" {
  type        = string
  description = "Node default root volume pool"
  default     = null
}

variable "root_volume_size" {
  type        = number
  description = "Node default root volume size in bytes"
  default     = null
}

variable "root_base_volume_name" {
  type        = string
  description = "Node default base root volume name"
  nullable    = false
}

variable "root_base_volume_pool" {
  type        = string
  description = "Node default base root volume pool"
  default     = null
}

variable "log_volume_pool" {
  type        = string
  description = "Node default log volume pool"
  default     = null
}

variable "log_volume_size" {
  type        = number
  description = "Node default log volume size in bytes"
  default     = null
}

variable "data_volume_pool" {
  type        = string
  description = "Node default data volume pool"
  default     = null
}

variable "data_volume_size" {
  type        = number
  description = "Node default data volume size in bytes"
  default     = null
}

variable "backup_volume_pool" {
  type        = string
  description = "Node default backup volume pool"
  default     = null
}

variable "backup_volume_size" {
  type        = number
  description = "Node default backup volume size in bytes"
  default     = null
}

variable "ignition_pool" {
  type        = string
  description = "Default ignition files pool"
  default     = null
}

variable "wait_for_lease" {
  type        = bool
  description = "Wait for network lease"
  default     = null
}

variable "autostart" {
  type        = bool
  description = "Autostart with libvirt host"
  default     = null
}

variable "network_bridge" {
  type        = string
  description = "Libvirt default network bridge name for VMs"
  default     = null
}

variable "network_id" {
  type        = string
  description = "Libvirt default network id for VMs"
  default     = null
}

variable "network_name" {
  type        = string
  description = "Libvirt default network name for VMs"
  default     = null
}
