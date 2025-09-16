#!/bin/bash

# Função para verificar se a VM está acessível
check_vm_status() {
    local vm_id=$TEMPLATE_ID
    local max_attempts=30
    local attempt=1
    
    echo "Verificando status da VM..."
    while [ $attempt -le $max_attempts ]; do
        if qm status $vm_id | grep -q "running"; then
            echo "VM está em execução"
            # Aguarda 30 segundos para o sistema inicializar completamente
            sleep 30
            return 0
        fi
        echo "Tentativa $attempt de $max_attempts - VM ainda não está pronta..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "Erro: VM não iniciou corretamente após $max_attempts tentativas"
    return 1
}

# Função para verificar conectividade da VM
check_vm_network() {
    local vm_id=$TEMPLATE_ID
    local max_attempts=10
    local attempt=1
    
    echo "Verificando conectividade da VM..."
    while [ $attempt -le $max_attempts ]; do
        if qm guest exec "$vm_id" -- ping -c 1 8.8.8.8 >/dev/null 2>&1; then
            echo "VM tem conectividade com a internet"
            return 0
        fi
        echo "Tentativa $attempt de $max_attempts - Aguardando conectividade..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "Erro: VM não tem conectividade com a internet"
    return 1
}

# Função para verificar qemu-guest-agent
check_qemu_agent() {
    local vm_id=$TEMPLATE_ID
    local max_attempts=10
    local attempt=1
    
    echo "Verificando qemu-guest-agent..."
    while [ $attempt -le $max_attempts ]; do
        # Tenta executar um comando simples para testar o qemu-guest-agent
        if qm guest exec "$vm_id" -- echo "test" >/dev/null 2>&1; then
            echo "qemu-guest-agent está funcionando"
            return 0
        fi
        echo "Tentativa $attempt de $max_attempts - Aguardando qemu-guest-agent..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "Erro: qemu-guest-agent não está respondendo"
    return 1
}

echo "Informe o número do ID do template:"
read TEMPLATE_ID

echo "Informe o nome do template:"
read TEMPLATE_NAME

echo "Informe o usuário para o template:"
read USERNAME

echo "Informe a senha para o template:"
read PASSWORD

echo "Informe o hostname para o template:"
read HOSTNAME

echo "Starting Debian template creation..."

# Define o nome do arquivo da imagem
IMAGE_FILE="debian-12-genericcloud-amd64.qcow2"

# Verifica se a imagem já existe
if [ -f "$IMAGE_FILE" ]; then
    echo "Imagem existente encontrada. Removendo..."
    rm -f "$IMAGE_FILE"
fi

echo "Downloading Debian cloud image..."
wget -O "$IMAGE_FILE" "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"

echo "Creating template with ID $TEMPLATE_ID..."

qm create $TEMPLATE_ID \
    --name $TEMPLATE_NAME \
    --memory 2048 \
    --cores 2 \
    --net0 virtio,bridge=vmbr0
    
# Wait for VM to be ready
sleep 15

qm importdisk $TEMPLATE_ID $IMAGE_FILE local-lvm

rm -f "$IMAGE_FILE"

sleep 10

qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$TEMPLATE_ID-disk-0

qm set $TEMPLATE_ID --ide2 local-lvm:cloudinit

qm set $TEMPLATE_ID --boot c --bootdisk scsi0

qm set $TEMPLATE_ID --agent enabled=1

qm set $TEMPLATE_ID --ipconfig0 ip=dhcp

# Criar arquivo user-data do cloud-init
mkdir -p /var/lib/vz/snippets
cat > /var/lib/vz/snippets/user-data.yml << EOL
#cloud-config
hostname: $HOSTNAME
user: $USERNAME
password: $PASSWORD
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
      ExecStart=/usr/sbin/qemu-ga \\
        --method=virtio-serial \\
        --path=/dev/virtio-ports/org.qemu.guest_agent.0 \\
        --blacklist=guest-file-open,guest-file-close,guest-file-read,guest-file-write,guest-file-seek,guest-file-flush
      Restart=always
      RestartSec=0

      [Install]
      WantedBy=multi-user.target
runcmd:
  - systemctl daemon-reload
  - systemctl enable qemu-guest-agent.service
  - systemctl start qemu-guest-agent.service
EOL

qm set $TEMPLATE_ID --ciuser $USERNAME

qm set $TEMPLATE_ID --cipassword $PASSWORD

qm set $TEMPLATE_ID --cicustom "user=local:snippets/user-data.yml"

# Iniciar VM para testes
echo "Iniciando VM para testes..."
qm start $TEMPLATE_ID

# Verificar status da VM
if ! check_vm_status $TEMPLATE_ID; then
    echo "Erro: Falha ao iniciar a VM"
    exit 1
fi

# Verificar qemu-guest-agent
if ! check_qemu_agent $TEMPLATE_ID; then
    echo "Erro: qemu-guest-agent não está funcionando"
    exit 1
fi

# Verificar conectividade
if ! check_vm_network $TEMPLATE_ID; then
    echo "Erro: VM não tem conectividade com a internet"
    exit 1
fi

echo "Todos os testes passaram com sucesso!"

# Desligar VM
echo "Desligando VM..."
qm shutdown $TEMPLATE_ID
sleep 30

# Create the template
echo "Creating template from VM $TEMPLATE_ID..."
qm template $TEMPLATE_ID

sleep 15

qm set $TEMPLATE_ID --description "Template for Debian 12 with qemu-guest-agent installed and tested"

echo "Template creation completed successfully!"