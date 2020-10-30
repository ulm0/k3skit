variable agents { default = 1 }
variable k3skit_kernel { default = "https://github.com/ulm0/k3skit/releases/download/v1.19.3-k3s1/k3s-kernel" }
variable k3skit_os { default = "https://github.com/ulm0/k3skit/releases/download/v1.19.3-k3s1/k3s-initrd.img" }
variable libvirt_pool { default = "/tmp/libvirt-pool-k3skit" }
variable private_key_filename { default = "./default.pem" }
