resource libvirt_volume agent_os {
  count  = var.agents
  name   = format("k3skit-agent-%s-os.img", count.index)
  pool   = libvirt_pool.k3skit.name
  source = var.k3skit_os
  format = "raw"
}

resource libvirt_volume agent_volume {
  count  = var.agents
  name   = format("k3skit-agent-%s-volume.img", count.index)
  pool   = libvirt_pool.k3skit.name
  size   = 20 * 1024 * 1024 * 1024 # Size in bytes (N  (GiB) * 1024 (MiB) * 1024 (KiB) * 1024 (Bytes))
  format = "raw"
}

resource libvirt_volume agent_kernel {
  count  = var.agents
  name   = format("k3skit-agent-%s-kernel.img", count.index)
  source = var.k3skit_kernel
  pool   = libvirt_pool.k3skit.name
  format = "raw"
}

data template_file agent_metadata {
  count    = var.agents
  template = file(format("%s/files/agent.yml", path.module))
  vars = {
    authorized_key = tls_private_key.default.public_key_openssh
    server         = local.kubeconfig.clusters.0.cluster.server
    hostname       = format("k3skit-agent-%s", count.index)
    token          = data.external.token.result.token
  }
}

resource libvirt_cloudinit_disk agent_metadata {
  count     = var.agents
  name      = format("k3skit-agent-%s-metadata.iso", count.index)
  user_data = jsonencode(yamldecode(element(data.template_file.agent_metadata.*.rendered, count.index)))
  pool      = libvirt_pool.k3skit.name
}

resource libvirt_domain agent {
  depends_on = [libvirt_domain.server]
  count      = var.agents
  name       = format("k3skit-agent-%s", count.index)
  memory     = "2048"
  vcpu       = 1
  qemu_agent = false
  kernel     = element(libvirt_volume.agent_kernel.*.id, count.index)
  initrd     = element(libvirt_volume.agent_os.*.id, count.index)
  cmdline = [
    {
      console     = "tty0"
      page_poison = "1"
    }
  ]

  cloudinit = element(libvirt_cloudinit_disk.agent_metadata.*.id, count.index)

  network_interface {
    network_name   = "default"
    hostname       = format("k3skit-agent-%s", count.index)
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
    volume_id = element(libvirt_volume.agent_volume.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
