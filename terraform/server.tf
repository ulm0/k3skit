resource libvirt_volume server_os {
  name   = "k3skit-server-os.img"
  pool   = libvirt_pool.k3skit.name
  source = var.k3skit_os
  format = "raw"
}

resource libvirt_volume server_volume {
  name   = "k3skit-server-volume.img"
  pool   = libvirt_pool.k3skit.name
  size   = 20 * 1024 * 1024 * 1024 # Size in bytes (N  (GiB) * 1024 (MiB) * 1024 (KiB) * 1024 (Bytes))
  format = "raw"
}

resource libvirt_volume server_kernel {
  source = var.k3skit_kernel
  name   = "k3skit-server-kernel.img"
  pool   = libvirt_pool.k3skit.name
  format = "raw"
}

data template_file server_metadata {
  template = file(format("%s/files/server.yml", path.module))
  vars = {
    authorized_key = tls_private_key.default.public_key_openssh
  }
}

resource libvirt_cloudinit_disk server_metadata {
  name      = "k3skit-server-metadata.iso"
  user_data = jsonencode(yamldecode(data.template_file.server_metadata.rendered))
  pool      = libvirt_pool.k3skit.name
}

resource libvirt_domain server {
  name       = "k3skit-server"
  memory     = "2048"
  vcpu       = 1
  qemu_agent = false
  kernel     = libvirt_volume.server_kernel.id
  initrd     = libvirt_volume.server_os.id
  cmdline = [
    {
      console     = "tty0"
      page_poison = "1"
    }
  ]

  cloudinit = libvirt_cloudinit_disk.server_metadata.id

  network_interface {
    network_name   = "default"
    hostname       = "k3skit-server"
    wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.server_volume.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
