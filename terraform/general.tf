resource libvirt_pool k3skit {
  name = "k3skit"
  type = "dir"
  path = var.libvirt_pool
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

data external token {
  depends_on = [libvirt_domain.server]
  program    = ["bash", format("%s/files/get_token.sh", path.module)]
  query = {
    private_key = local_file.private_key_pem.filename
    server      = libvirt_domain.server.network_interface.0.addresses.0
  }
}

data external kubeconfig {
  depends_on = [libvirt_domain.server]
  program    = ["bash", format("%s/files/get_kubeconfig.sh", path.module)]
  query = {
    private_key = local_file.private_key_pem.filename
    server      = libvirt_domain.server.network_interface.0.addresses.0
  }
}

resource local_file kubeconfig {
  content         = data.external.kubeconfig.result.kubeconfig
  file_permission = "0644"
  filename        = format("%s/%s", path.root, "kubeconfig.yml")
}
