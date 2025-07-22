# Linux Configuration Automation and IaC with Proxmox and Terraform

This project automates the creation and configuration of virtual machines (VMs) in **Proxmox** using **Terraform** and **Cloud-init** scripts. It streamlines template creation, infrastructure-as-code (IaC) management, and verification of essential services like the `qemu-guest-agent` to ensure seamless VM operation.

---

## 🚀 Project Overview

The goal is to automate VM provisioning in Proxmox with a scalable, repeatable, and programmable approach using IaC principles. This includes setting up VMs with specific CPU, memory, disk, and network configurations, and initializing them with custom settings via Cloud-init.

### 🛠️ Key Components

- **Terraform**: Defines and provisions infrastructure as code, managing VM creation and resource allocation in Proxmox.
- **Proxmox**: The virtualization platform hosting the VMs.
- **Cloud-init**: Automates VM initialization, including OS configuration, user creation, package installation, and networking setup.
- **Shell Scripts**: Facilitates VM template creation, testing, and validation of services like `qemu-guest-agent` and network connectivity.

---

## 📂 Project Structure

The project is organized into the following key components, typically represented as separate files but consolidated here for clarity:

- **Main Terraform Configuration**: Defines VM provisioning in Proxmox with flexible variable-based settings.
- **Variables**: Customizable variables for VM configurations (e.g., CPU, memory, disk sizes).
- **Cloud-init Configuration**: Automates VM initialization.
- **Template Creation Script**: Shell script for creating and testing Proxmox VM templates.

---

## ✅ Prerequisites

Before starting, ensure the following are set up:

- **Proxmox**: Installed on a physical or virtual server.
- **Terraform**: Installed for infrastructure automation.
- **QEMU Guest Agent**: Installed on VMs for enhanced integration with Proxmox.
- **Cloud-init**: Configured for VM initialization during boot.

---

## 🛠️ How to Use

Follow these steps to set up and deploy the infrastructure:

### 1. Configure the Proxmox Provider

Define Proxmox-specific variables such as the API URL and access token. Replace default values with your environment's settings.

```hcl
# Variables for Proxmox configuration
variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://your-proxmox-server:8006/api2/json"
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  default     = "your-token-id"
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  default     = "your-token-secret"
}

variable "pm_tls_insecure" {
  description = "Disable TLS verification"
  type        = bool
  default     = true
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "cloudinit-example"
}

variable "vm_memory" {
  description = "VM memory in MB"
  type        = number
  default     = 2048
}

variable "vm_cpu" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_clone" {
  description = "Template to clone from"
  type        = string
  default     = "ubuntu-template"
}

variable "vm_root_disk_size" {
  description = "Size of root disk in GB"
  type        = string
  default     = "32"
}

variable "vm_data_disk_size" {
  description = "Size of data disk in GB"
  type        = string
  default     = "64"
}

variable "vm_ciuser" {
  description = "Cloud-init user"
  type        = string
  default     = "user"
}

variable "vm_cipassword" {
  description = "Cloud-init password"
  type        = string
  default     = "user"
}