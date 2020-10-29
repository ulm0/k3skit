output ip { value = libvirt_domain.server.network_interface.0.addresses }
output kubeconfig { value = data.external.kubeconfig.result.kubeconfig }
output token { value = data.external.token.result.token }
