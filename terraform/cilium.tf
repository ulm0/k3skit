resource helm_release cilium {
  depends_on = [libvirt_domain.server]
  name       = "cilium"
  atomic     = true
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.8.4"
  namespace  = "kube-system"
  set {
    name  = "global.hubble.metrics.enabled"
    value = "{dns,drop,tcp,flow,port-distribution,icmp,http}"
  }
  values = [
    yamlencode(
      {
        config = {
          ipam = "kubernetes"
        }
        global = {
          bpf = {
            monitorAggregation = "maximum"
            preallocateMaps    = true
            waitForMount       = true
          }
          cluster = {
            name = yamldecode(data.external.kubeconfig.result.kubeconfig).clusters.0.name
          }
          containerRuntime = {
            integration = "containerd"
            socketPath  = "/var/run/k3s/containerd/containerd.sock"
          }
          debug = {
            enabled = true
          }
          device = "eth0"
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
          k8s = {
            requireIPv4PodCIDR = true
          }
          k8sServiceHost       = libvirt_domain.server.network_interface.0.addresses.0
          k8sServicePort       = 6443
          kubeProxyReplacement = "strict"
          # nodeinit = {
          #   enabled = true
          # }
          nodePort = {
            enabled = true
            mode    = "hybrid"
          }
          operatorPrometheus = {
            enabled = true
          }
          prometheus = {
            enabled = true
          }
          psp = {
            enabled = true
          }
          tunnel = "geneve"
        }
        # nodeinit = {
        #   restartPods = var.cilium_node_init_restart_pods
        # }
        operator = {
          numReplicas = 1
        }
      }
    )
  ]
}
