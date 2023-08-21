terraform {
  cloud {
    organization = "jobcespedes"
    hostname     = "app.terraform.io"
    workspaces {
      name = "libvirt_fcos_maddy"
    }
  }
}
