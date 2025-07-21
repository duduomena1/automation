# Declaração do provider Proxmox
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

# Configuração do provider Proxmox
provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

# Recurso para criar a VM
resource "proxmox_vm_qemu" "app_vm" {
  # Configurações gerais da VM
  name        = var.vm_name
  target_node = var.proxmox_node
  vmid        = var.vm_id
  desc        = "VM para aplicação - Cloud-Init"
  onboot      = true
  agent       = 1

  # Configurações de clonagem a partir de um template
  clone      = "ubuntu-improved"
  full_clone = true

  ciuser     = "ubuntu"
  cipassword = var.ci_password

  sshkeys    = file("~/.ssh/id_rsa.pub")

  serial {
    id   = 0
    type = "socket"
  }

  vga {
    type = "serial0"
  }

  # Configurações de hardware
  cores    = var.cpu_cores
  sockets  = 1
  cpu_type = "host"
  memory   = var.memory_mb

  # Configuração do boot
  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"
  machine  = "q35"

  # Configuração de disco principal
  disk {
    slot     = "scsi0"
    type     = "disk"
    storage  = var.storage_pool
    size     = var.disk_size
    discard  = true
    iothread = true
  }

  # Disco adicional
  disk {
    slot     = "scsi1"
    type     = "disk"
    storage  = var.storage_pool
    size     = var.additional_disk_size
    discard  = true
    iothread = true
  }

  # Configuração de rede
  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    tag      = 0
    firewall = false
  }

  # Configuração de rede básica - usando DHCP
  ipconfig0  = "ip=dhcp"
  nameserver = "8.8.8.8"

  # Provisioners removidos temporariamente - configure manualmente após criação

  # Aguardar a VM estar pronta
  lifecycle {
    ignore_changes = [
      network
    ]
  }
}

# Variáveis para personalização
variable "proxmox_api_url" {
  description = "URL da API do Proxmox"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "ID do token da API"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Segredo do token da API"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nó Proxmox onde a VM será criada"
  type        = string
  default     = "pve"
}

variable "vm_name" {
  description = "Nome da VM"
  type        = string
  default     = "app-vm"
}

variable "vm_id" {
  description = "ID da VM (0 para autoatribuição)"
  type        = number
  default     = 0
}

variable "template_name" {
  description = "Nome do template Linux"
  type        = string
  default     = "ubuntu-base"
}

variable "cpu_cores" {
  description = "Número de núcleos da CPU"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memória RAM em MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Tamanho do disco principal"
  type        = string
  default     = "20G"
}

variable "additional_disk_size" {
  description = "Tamanho do disco adicional"
  type        = string
  default     = "50G"
}

variable "storage_pool" {
  description = "Pool de armazenamento"
  type        = string
  default     = "local-lvm"
}

variable "vm_ip" {
  description = "Endereço IP da VM"
  type        = string
  default     = "192.168.102.100"
}

variable "gateway_ip" {
  description = "Endereço do gateway"
  type        = string
  default     = "192.168.102.1"
}

variable "ssh_user" {
  description = "Usuário SSH para conectar na VM"
  type        = string
  default     = "root"
}

variable "ssh_password" {
  description = "Senha SSH para conectar na VM"
  type        = string
  sensitive   = true
}

variable "ci_password" {
  description = "Senha para conectar na VM"
  type        = string
  sensitive   = true
}

# Output para mostrar IP da VM
output "vm_ip" {
  value = proxmox_vm_qemu.app_vm.default_ipv4_address
}

output "vm_name" {
  value = var.vm_name
}
