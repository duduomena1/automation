#!/bin/bash

# Script para testar a conectividade de rede das VMs

echo "=== Testando conectividade das VMs ==="
echo

# IPs das VMs
VMS=(
    "192.168.101.210:aplicacao"
    "192.168.101.211:banco"
    "192.168.101.212:nfs"
    "192.168.101.213:superset"
)

# Função para testar conectividade
test_vm() {
    local ip=$1
    local name=$2
    
    echo "Testando VM $name ($ip)..."
    
    # Teste de ping
    if ping -c 3 -W 5 "$ip" > /dev/null 2>&1; then
        echo "  ✓ Ping OK"
        
        # Teste SSH se estiver disponível
        if timeout 5 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@"$ip" "echo 'SSH OK'" 2>/dev/null; then
            echo "  ✓ SSH OK"
            
            # Teste de conectividade à internet
            if timeout 10 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@"$ip" "ping -c 2 8.8.8.8" > /dev/null 2>&1; then
                echo "  ✓ Internet OK"
            else
                echo "  ✗ Internet FAIL"
            fi
            
            # Verificar MAC address
            mac=$(timeout 10 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@"$ip" "ip link show | grep -A1 'state UP' | grep link/ether | awk '{print \$2}'" 2>/dev/null)
            if [ -n "$mac" ]; then
                echo "  ℹ MAC: $mac"
            fi
        else
            echo "  ✗ SSH FAIL (pode estar inicializando ainda)"
        fi
    else
        echo "  ✗ Ping FAIL"
    fi
    echo
}

# Testar cada VM
for vm_info in "${VMS[@]}"; do
    IFS=':' read -r ip name <<< "$vm_info"
    test_vm "$ip" "$name"
done

echo "=== Verificando MACs únicos ==="
echo "Execute este comando nas VMs para verificar MACs:"
echo "for ip in 192.168.101.210 192.168.101.211 192.168.101.212 192.168.101.213; do"
echo "  echo -n \"\$ip: \""
echo "  ssh root@\$ip \"ip link show | grep -A1 'state UP' | grep link/ether | awk '{print \\\$2}'\""
echo "done"