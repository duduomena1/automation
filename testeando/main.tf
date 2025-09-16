terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

# Criação das VMs usando for_each
resource "proxmox_vm_qemu" "vms" {
  for_each = var.vms

  vmid        = var.vmid_base + each.value.vmid_offset
  name        = "${var.client_name}-${each.key}-${var.environment}"
  target_node = var.target_node
  agent       = 1
  memory      = each.value.memory
  boot        = "order=scsi0"
  clone       = var.template_clone
  scsihw      = "virtio-scsi-single"
  vm_state    = "running"
  automatic_reboot = true

  # Cloud-init configuration
  ciupgrade    = true
  ipconfig0    = var.network_config[each.key].ip_config
  nameserver   = "8.8.8.8 8.8.4.4"
  searchdomain = "local"
  skip_ipv6    = true
  ciuser       = var.ci_user
  cipassword   = var.ci_password
  
  # Force VM to use cloud-init for proper network setup
  qemu_os    = "l26"
  os_type    = "cloud-init"

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  serial {
    id = 0
  }

  # Configuração de discos
  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.storage_name
          size    = each.value.root_disk_size
        }
      }
      # Disco adicional apenas se especificado (não para Superset)
      dynamic "scsi1" {
        for_each = each.value.data_disk_size != "0G" ? [1] : []
        content {
          disk {
            storage = var.storage_name
            size    = each.value.data_disk_size
          }
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = var.storage_name
        }
      }
    }
  }

  network {
    id     = 0
    bridge = var.network_bridge
    model  = "virtio"
    macaddr = var.network_config[each.key].mac_address
  }

  # Tags para organização
  tags = "${var.client_name},${each.key},${var.environment}"

  # Force unique identification for each VM
  lifecycle {
    create_before_destroy = true
  }

  # Ensure VM is properly configured with unique MAC
  provisioner "local-exec" {
    command = "echo 'VM ${var.client_name}-${each.key}-${var.environment} created with MAC ${var.network_config[each.key].mac_address}'"
  }
}
