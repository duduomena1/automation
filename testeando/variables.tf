# Configurações gerais do Proxmox
variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.101.30:8006/api2/json"
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  default     = "root@pam!terraform"
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  default     = "36ff7f9a-b540-429e-a2be-3b1b5d1eaa16"
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Allow insecure TLS connections"
  type        = bool
  default     = true
}

variable "target_node" {
  description = "Proxmox target node"
  type        = string
  default     = "pve-dev"
}

variable "template_clone" {
  description = "Template to clone for the VMs"
  type        = string
  default     = "template"
}

variable "network_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "storage_name" {
  description = "Storage name for VM disks"
  type        = string
  default     = "local-lvm"
}

# Configuração do cliente/projeto
variable "client_name" {
  description = "Nome do cliente (será usado como prefixo das VMs)"
  type        = string
  default     = "AMC"
}

variable "environment" {
  description = "Environment (prod, dev, test)"
  type        = string
  default     = "prod"
}

# Configurações específicas das VMs
variable "vms" {
  description = "Configuration for each VM"
  type = map(object({
    memory         = number
    cores          = number
    root_disk_size = string
    data_disk_size = string
    filesystem     = string
    mount_options  = list(string)
    vmid_offset    = number
  }))
  default = {
    "aplicacao" = {
      memory         = 1228
      cores          = 16
      root_disk_size = "20G"
      data_disk_size = "0G"
      filesystem     = "xfs"
      mount_options  = ["defaults"]
      vmid_offset    = 5
    }
    "banco" = {
      memory         = 3278
      cores          = 32
      root_disk_size = "20G"
      data_disk_size = "5G"
      filesystem     = "xfs"
      mount_options  = ["defaults", "noatime"]
      vmid_offset    = 2
    }
    "nfs" = {
      memory         = 9216
      cores          = 8
      root_disk_size = "20G"
      data_disk_size = "0G"
      filesystem     = "btrfs"
      mount_options  = ["defaults"]
      vmid_offset    = 3
    }
    "superset" = {
      memory         = 8192
      cores          = 4
      root_disk_size = "20G"
      data_disk_size = "0G"    # Sem disco adicional
      filesystem     = "ext4"
      mount_options  = ["defaults"]
      vmid_offset    = 4
    }
  }
}

# Configurações de rede com IPs fixos para evitar conflitos DHCP
variable "network_config" {
  description = "Network configuration for VMs"
  type = map(object({
    ip_config   = string
    mac_address = string
  }))
  default = {
    "aplicacao" = {
      ip_config   = "ip=192.168.101.210/24,gw=192.168.101.254"
      mac_address = "52:54:00:AA:01:05"
    }
    "banco" = {
      ip_config   = "ip=192.168.101.211/24,gw=192.168.101.254"
      mac_address = "52:54:00:AA:01:02"
    }
    "nfs" = {
      ip_config   = "ip=192.168.101.212/24,gw=192.168.101.254"
      mac_address = "52:54:00:AA:01:03"
    }
    "superset" = {
      ip_config   = "ip=192.168.101.213/24,gw=192.168.101.254"
      mac_address = "52:54:00:AA:01:04"
    }
  }
}

# Configurações de cloud-init
variable "ci_user" {
  description = "Cloud-init user for the VMs"
  type        = string
  default     = "root"
}

variable "ci_password" {
  description = "Cloud-init password for the VMs"
  type        = string
  default     = "123456"
  sensitive   = true
}

# VMID base (será somado com o offset de cada VM)
variable "vmid_base" {
  description = "Base VMID (will be added to each VM's offset)"
  type        = number
  default     = 200
}
