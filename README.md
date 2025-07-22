Linux Configuration Automation and IaC with Proxmox and Terraform

This project aims to automate the creation and configuration of virtual machines (VMs) in Proxmox using Terraform and Cloud-init scripts. The automation process includes template creation, infrastructure-as-code (IaC) configuration, and verification of essential services like the qemu-guest-agent to ensure the proper operation of the VMs.
Project Components:

    Terraform: Used to create and configure the infrastructure as code, including creating VMs in Proxmox and configuring resources such as CPU, memory, disks, and network settings.

    Proxmox: The virtualization platform used to host the VMs.

    Cloud-init: A tool used to automatically initialize the VMs by configuring the operating system, creating users, installing essential packages, and setting up networking.

    Shell Scripts: Used to create and test VM templates in Proxmox, as well as ensuring the proper configuration of qemu-guest-agent and network connectivity.

Project Structure

The project contains the following main files:

    main.tf: The primary Terraform file that configures VM creation in Proxmox and uses variables to make the configuration flexible.

    variables.tf: Defines the variables for customizing the VM configuration, such as CPU, memory, disks, and other settings.

    user-data.yml: The Cloud-init configuration file that is used to automatically initialize the VM.

    create-template.sh: A shell script that creates and tests the VM templates in Proxmox, including the process of creating the image, configuring Cloud-init, and verifying essential services.

Prerequisites

    Proxmox: Proxmox should be installed on a physical or virtual server.

    Terraform: A tool for infrastructure automation (IaC).

    QEMU Guest Agent: The qemu-guest-agent must be installed on the VMs for better integration between the guest OS and Proxmox.

    Cloud-init: Used to customize the VM during boot.

How to Use
1. Proxmox Provider Configuration

In the variables.tf file, define the variables related to Proxmox, such as the API URL and access token. Make sure to replace the default values with your actual settings.
2. Resource Definition in main.tf

The main.tf file defines the resources that will be created. In this case, it creates a VM in Proxmox based on an existing template and configures Cloud-init to initialize the VM.

Example configuration in main.tf:

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
  cicustom    = "vendor=local:snippets/user-data.yml"
  ciupgrade   = true
  ipconfig0   = "ip=dhcp,ip6=dhcp"
  skip_ipv6   = true
  ciuser      = var.vm_ciuser
  cipassword  = var.vm_cipassword
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
      scsi1 {
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

3. Cloud-init Configuration

The user-data.yml file is used to configure the VM during boot. In the example below, Cloud-init is configured to set the hostname, create a user, set the password, and install packages like qemu-guest-agent and ansible.

Example configuration in user-data.yml:

#cloud-config
hostname: user
user: user
password: user
chpasswd: { expire: False }
ssh_pwauth: True
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - ansible
write_files:
  - path: /etc/systemd/system/qemu-guest-agent.service
    content: |
      [Unit]
      Description=QEMU Guest Agent
      BindsTo=dev-virtio\x2dports-org.qemu.guest_agent.0.device
      After=dev-virtio\x2dports-org.qemu.guest_agent.0.device

      [Service]
      ExecStart=/usr/sbin/qemu-ga \
        --method=virtio-serial \
        --path=/dev/virtio-ports/org.qemu.guest_agent.0 \
        --blacklist=guest-file-open,guest-file-close,guest-file-read,guest-file-write,guest-file-seek,guest-file-flush
      Restart=always
      RestartSec=0

      [Install]
      WantedBy=multi-user.target
runcmd:
  - systemctl daemon-reload
  - systemctl enable qemu-guest-agent.service
  - systemctl start qemu-guest-agent.service

4. Template Creation Script

The create-template.sh script is used to create and test the VM template before applying the infrastructure. It checks if the VM is running, ensures qemu-guest-agent is working, and verifies network connectivity.
5. Running the Infrastructure

    Clone the VM from the Template: After the template is created, use Terraform to clone the VM and configure the infrastructure.

    Test the Infrastructure: Run tests to ensure that essential services are working correctly.

6. Install Terraform and Apply Configurations

    Install Terraform:

        Install Terraform

    Run Terraform:

        Initialize Terraform with terraform init.

        Apply the configuration with terraform apply.

Conclusion

This project automates the creation and configuration of VMs in Proxmox, integrating Terraform for Infrastructure as Code (IaC) and Cloud-init for VM initialization. The automation of the template creation allows you to quickly create, configure, and test your VMs with additional disks for handling large data volumes, ideal for camera monitoring systems.

This README.md serves as a comprehensive guide for your project, explaining how to configure and run the automated infrastructure on Proxmox with Terraform. Let me know if you need further adjustments or additional details!