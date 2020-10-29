locals {
  kubeconfig = yamldecode(data.external.kubeconfig.result.kubeconfig)
}
