resource helm_release cilium {
  depends_on = [libvirt_domain.server]
  name       = "cilium"
  atomic     = true
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.9.0"
  namespace  = "kube-system"
  set {
    name  = "hubble.metrics.enabled"
    value = "{dns,drop,tcp,flow,port-distribution,icmp,http}"
  }
  values = [
    yamlencode(
      {
        ipam = {
          mode = "kubernetes"
        }
        debug = {
          enabled = true
        }
        k8sServiceHost = libvirt_domain.server.network_interface.0.addresses.0
        k8sServicePort = 6443
        k8s = {
          requireIPv4PodCIDR = true
        }
        priorityClassName = "system-cluster-critical"
        bpf = {
          monitorAggregation = "maximum"
          preallocateMaps    = true
          waitForMount       = true
        }
        containerRuntime = {
          integration = "containerd"
          socketPath  = "/var/run/k3s/containerd/containerd.sock"
        }
        nodePort = {
          enabled = true
        }
        prometheus = {
          enabled = true
          serviceMonitor = {
            enabled = false
          }
        }
        cluster = {
          name = yamldecode(data.external.kubeconfig.result.kubeconfig).clusters.0.name
        }
        externalIPs = {
          enabled = true
        }
        hostPort = {
          enabled = true
        }
        hostServices = {
          enabled = true
        }
        hubble = {
          enabled       = true
          listenAddress = ":4244"
          relay = {
            enabled = true
          }
          ui = {
            enabled = true
          }
        }
        kubeProxyReplacement = "strict"
        tunnel               = "geneve"
        operator = {
          replicas = 1
        }
      }
    )
  ]
}
