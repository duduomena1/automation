provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

resource "proxmox_vm_qemu" "cloudinit-example" {
  vmid        = 0
  name        = var.vm_name
  target_node = "pve"
  agent       = 1
  memory      = var.vm_memory
  boot        = "order=scsi0"
  clone       = var.vm_clone
  scsihw      = "virtio-scsi-single"
  vm_state    = "running"
  automatic_reboot = true

  cicustom   = "vendor=local:snippets/user-data.yml"
  ciupgrade  = true
  ipconfig0  = "ip=dhcp,ip6=dhcp"
  skip_ipv6  = true
  ciuser     = var.vm_ciuser
  cipassword = var.vm_cipassword

  cpu {
    cores   = var.vm_cpu
    sockets = 1
    type    = "host"
  }

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = var.vm_root_disk_size
        }
      }
      scsi1 { # Novo disco para /data
        disk {
          storage = "local-lvm"
          size    = var.vm_data_disk_size
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }
}

terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc03"
    }
  }
}