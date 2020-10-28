terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

variable private_key_filename { default = "./default.pem" }

provider libvirt {
  uri = "qemu:///system"
}

resource tls_private_key default {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource local_file private_key_pem {
  filename        = var.private_key_filename
  content         = tls_private_key.default.private_key_pem
  file_permission = "0600"
}

resource libvirt_pool linuxkit {
  name = "linuxkit"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-linuxkit"
}

resource libvirt_volume linuxkit_template {
  name   = "linuxkit-template.img"
  pool   = libvirt_pool.linuxkit.name
  source = "../k3s-initrd.img"
  format = "raw"
}

resource libvirt_volume linuxkit {
  name   = "linuxkit.img"
  pool   = libvirt_pool.linuxkit.name
  size   = 20 * 1024 * 1024 * 1024 # Size in bytes (N  (GiB) * 1024 (MiB) * 1024 (KiB) * 1024 (Bytes))
  format = "raw"
}

resource libvirt_volume kernel {
  source = "../k3s-kernel"
  name   = "linuxkit-kernel"
  pool   = libvirt_pool.linuxkit.name
  format = "raw"
}

data template_file meta_data {
  template = file(format("%s/files/userdata.yml", path.module))
  vars = {
    authorized_key = tls_private_key.default.public_key_openssh
  }
}

resource libvirt_cloudinit_disk common_init {
  name      = "commoninit.iso"
  user_data = jsonencode(yamldecode(data.template_file.meta_data.rendered))
  pool      = libvirt_pool.linuxkit.name
}

resource libvirt_domain linuxkit {
  name       = "linuxkit-terraform"
  memory     = "2048"
  vcpu       = 1
  qemu_agent = true
  kernel     = libvirt_volume.kernel.id
  initrd     = libvirt_volume.linuxkit_template.id
  cmdline = [
    {
      console     = "tty0"
      page_poison = "1"
    }
  ]

  cloudinit = libvirt_cloudinit_disk.common_init.id

  network_interface {
    network_name   = "default"
    hostname       = "linuxkit-terraform"
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
    volume_id = libvirt_volume.linuxkit.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output ip { value = libvirt_domain.linuxkit.network_interface.0.addresses }
