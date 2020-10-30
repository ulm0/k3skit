resource null_resource remove_agent {
  depends_on = [libvirt_domain.server, libvirt_domain.agent, local_file.kubeconfig, local_file.private_key_pem]
  count      = var.agents
  triggers = {
    agent       = format("k3skit-agent-%s", count.index + 1)
    kubeconfig  = local_file.kubeconfig.filename
    private_key = local_file.private_key_pem.filename
    server      = libvirt_domain.server.network_interface.0.addresses.0
    user        = "root"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = format("kubectl --kubeconfig=%s drain %s --ignore-daemonsets --delete-local-data", self.triggers.kubeconfig, self.triggers.agent)
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = format("kubectl --kubeconfig=%s delete node %s", self.triggers.kubeconfig, self.triggers.agent)
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = format("ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i %s %s@%s sed -i -e '/%s/d' /var/lib/rancher/k3s/server/cred/node-passwd", self.triggers.private_key, self.triggers.user, self.triggers.server, self.triggers.agent)
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = format("kubectl --kubeconfig=%s delete po --force --grace-period=0 -n=kube-system --selector=k8s-app=metrics-server", self.triggers.kubeconfig)
    on_failure = continue
  }
}
