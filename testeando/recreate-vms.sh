#!/bin/bash

# Script para forçar recriação das VMs com configuração limpa

echo "=== Forçando recriação das VMs para resolver problemas de rede ==="
echo

# Opção 1: Destruir e recriar todas as VMs
echo "OPÇÃO 1: Destruir e recriar todas as VMs (mais seguro)"
echo "terraform destroy -auto-approve"
echo "terraform apply -auto-approve"
echo

# Opção 2: Taint específico de cada VM
echo "OPÇÃO 2: Marcar VMs para recriação (mais granular)"
echo "terraform taint 'proxmox_vm_qemu.vms[\"aplicacao\"]'"
echo "terraform taint 'proxmox_vm_qemu.vms[\"banco\"]'"
echo "terraform taint 'proxmox_vm_qemu.vms[\"nfs\"]'"
echo "terraform taint 'proxmox_vm_qemu.vms[\"superset\"]'"
echo "terraform apply -auto-approve"
echo

# Opção 3: Verificar configuração sem aplicar
echo "OPÇÃO 3: Verificar configuração"
echo "terraform plan"
echo

read -p "Escolha uma opção (1, 2, 3): " choice

case $choice in
    1)
        echo "Destruindo todas as VMs..."
        terraform destroy -auto-approve
        echo "Recriando VMs com nova configuração..."
        terraform apply -auto-approve
        ;;
    2)
        echo "Marcando VMs para recriação..."
        terraform taint 'proxmox_vm_qemu.vms["aplicacao"]'
        terraform taint 'proxmox_vm_qemu.vms["banco"]'
        terraform taint 'proxmox_vm_qemu.vms["nfs"]'
        terraform taint 'proxmox_vm_qemu.vms["superset"]'
        echo "Aplicando mudanças..."
        terraform apply -auto-approve
        ;;
    3)
        echo "Verificando configuração..."
        terraform plan
        ;;
    *)
        echo "Opção inválida"
        exit 1
        ;;
esac

echo
echo "=== Aguardando VMs inicializarem (60 segundos) ==="
sleep 60

echo "=== Testando conectividade ==="
./test-network.sh