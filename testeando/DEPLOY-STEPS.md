# Comandos para aplicar as mudanças no Terraform

## 1. Verificar o plano de execução
terraform plan

## 2. Aplicar as mudanças (isso irá recriar as VMs com novos MACs)
terraform apply

## 3. Comandos úteis para diagnóstico

### Verificar se as VMs foram criadas
terraform show | grep -E "(name|ipconfig0|mac_address)"

### Verificar o estado atual
terraform state list

### Se precisar forçar a recriação de uma VM específica
# terraform taint 'proxmox_vm_qemu.vms["aplicacao"]'
# terraform taint 'proxmox_vm_qemu.vms["banco"]'
# terraform taint 'proxmox_vm_qemu.vms["nfs"]'
# terraform taint 'proxmox_vm_qemu.vms["superset"]'

### Destruir e recriar todas as VMs (se necessário)
# terraform destroy
# terraform apply

## 4. Após aplicar, execute o script de teste
./test-network.sh