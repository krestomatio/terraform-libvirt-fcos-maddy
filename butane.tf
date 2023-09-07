data "template_file" "butane_snippet_install_maddy" {
  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    # pkg dependencies to be installed by additional-rpms.service
    - path: /var/lib/additional-rpms.list
      overwrite: false
      append:
        - inline: |
            fail2ban
            firewalld
    - path: /usr/local/bin/maddy-installer.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -e
          # vars

          ## firewalld rules
          if ! systemctl is-active firewalld &> /dev/null
          then
            echo "Enabling firewalld..."
            systemctl restart dbus.service
            restorecon -rv /etc/firewalld
            systemctl enable --now firewalld
            echo "Firewalld enabled..."
          fi
          # Add firewalld rules
          echo "Adding firewalld rules..."
          firewall-cmd --zone=public --permanent --add-port=25/tcp
          firewall-cmd --zone=public --permanent --add-port=465/tcp
          firewall-cmd --zone=public --permanent --add-port=587/tcp
          firewall-cmd --zone=public --permanent --add-port=143/tcp
          firewall-cmd --zone=public --permanent --add-port=993/tcp
          # firewall-cmd --zone=public --add-masquerade
          firewall-cmd --reload
          echo "Firewalld rules added..."

          # fail2ban
          echo "Adding fail2ban maddy files..."
          curl -L https://raw.githubusercontent.com/foxcpp/maddy/master/dist/fail2ban/filter.d/maddy-auth.conf -o /etc/fail2ban/filter.d/maddy-auth.conf
          curl -L https://raw.githubusercontent.com/foxcpp/maddy/master/dist/fail2ban/filter.d/maddy-dictonary-attack.conf -o /etc/fail2ban/filter.d/maddy-dictonary-attack.conf
          curl -L https://raw.githubusercontent.com/foxcpp/maddy/master/dist/fail2ban/jail.d/maddy-auth.conf -o /etc/fail2ban/jail.d/maddy-auth.conf
          curl -L https://raw.githubusercontent.com/foxcpp/maddy/master/dist/fail2ban/jail.d/maddy-dictonary-attack.conf -o /etc/fail2ban/jail.d/maddy-dictonary-attack.conf
          echo "Fail2ban maddy files added..."

          # selinux context to data dir
          chcon -Rt svirt_sandbox_file_t ${local.data_volume_path}

          # maddy.conf
          if [ ! -f ${local.data_volume_path}/maddy.conf ]; then
            curl -sL https://raw.githubusercontent.com/foxcpp/maddy/master/maddy.conf.docker -o ${local.data_volume_path}/maddy.conf
          fi

          # install
          echo "Installing maddy service..."
          podman kill maddy 2>/dev/null || echo
          podman rm maddy 2>/dev/null || echo
          podman create --pull never --rm --restart on-failure --stop-timeout ${local.systemd_stop_timeout} \
            --network host \
            %{~if var.cpus_limit > 0~}
            --cpus ${var.cpus_limit} \
            %{~endif~}
            %{~if var.memory_limit != ""~}
            --memory ${var.memory_limit} \
            %{~endif~}
            -e MADDY_HOSTNAME=${var.external_fqdn} \
            -e MADDY_DOMAIN=${var.primary_domain} \
            --volume /etc/localtime:/etc/localtime:ro \
            --volume "${local.data_volume_path}:/data" \
            --name maddy ${local.maddy_image}
          podman generate systemd --new \
            --restart-sec 15 \
            --start-timeout 180 \
            --stop-timeout ${local.systemd_stop_timeout} \
            --after maddy-image-pull.service \
            --name maddy > /etc/systemd/system/maddy.service
          systemctl daemon-reload
          systemctl enable maddy.service fail2ban.service
          echo "maddy service installed..."
systemd:
  units:
    - name: maddy-image-pull.service
      enabled: true
      contents: |
        [Unit]
        Description="Pull maddy image"
        Wants=network-online.target
        After=network-online.target
        Before=install-maddy.service
        Before=maddy.service

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=on-failure
        RestartSec=10
        TimeoutStartSec=180
        ExecStart=/usr/bin/podman pull ${local.maddy_image}

        [Install]
        WantedBy=multi-user.target
    - name: install-maddy.service
      enabled: true
      contents: |
        [Unit]
        Description=Install maddy
        # We run before `zincati.service` to avoid conflicting rpm-ostree
        # transactions.
        Before=zincati.service
        Wants=network-online.target
        After=network-online.target
        After=additional-rpms.service
        After=install-certbot.service
        After=maddy-image-pull.service
        OnSuccess=maddy.service
        OnSuccess=fail2ban.service
        ConditionPathExists=/usr/local/bin/maddy-installer.sh
        ConditionPathExists=!/var/lib/%N.done
        StartLimitInterval=500
        StartLimitBurst=3

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=on-failure
        RestartSec=60
        TimeoutStartSec=300
        ExecStart=/usr/local/bin/maddy-installer.sh
        ExecStart=/bin/touch /var/lib/%N.done

        [Install]
        WantedBy=multi-user.target
TEMPLATE
}

module "butane_snippet_install_certbot" {
  count = var.certbot != null ? 1 : 0

  source  = "krestomatio/butane-snippets/ct//modules/certbot"
  version = "0.0.12"

  domain       = var.external_fqdn
  http_01_port = var.certbot.http_01_port
  post_hook    = local.post_hook
  agree_tos    = var.certbot.agree_tos
  staging      = var.certbot.staging
  email        = var.certbot.email
}
