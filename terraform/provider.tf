terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

provider libvirt {
  uri = "qemu:///system"
}

provider helm {
  kubernetes {
    client_certificate     = base64decode(local.kubeconfig.users.0.user.client-certificate-data)
    client_key             = base64decode(local.kubeconfig.users.0.user.client-key-data)
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
    host                   = local.kubeconfig.clusters.0.cluster.server
    load_config_file       = false
    username               = local.kubeconfig.users.0.name
  }
}
