variable "vm_cpu" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 4
  
}

variable "vm_memory" {
  description = "Memory size for the VM in MB"
  type        = number
  default     = 8192
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "test-terraform0"
}

variable "vm_ciuser" {
  description = "Cloud-init user for the VM"
  type        = string
  default     = "root"
}

variable "vm_cipassword" {
  description = "Cloud-init password for the VM"
  type        = string
  default     = "123456"
}
variable "vm_clone" {
  description = "Template to clone for the VM"
  type        = string
  default     = "debian12-cloudinit"
}

variable "vm_root_disk_size" {
  description = "Size of the root disk for the VM"
  type        = string
  default     = "50G"
}

variable "vm_data_disk_size" {
  description = "Size of the data disk for the VM"
  type        = string
  default     = "500G"
}

variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://<PROXMOX_HOST>:8006/api2/json"
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  default     = "root@pam!terraform"
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  default     = ""
}

variable "pm_tls_insecure" {
  description = "Allow insecure TLS connections"
  type        = bool
  default     = true
}