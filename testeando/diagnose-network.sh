#!/bin/bash

# Script de diagnóstico avançado para problemas de rede

echo "=== DIAGNÓSTICO AVANÇADO DE REDE ==="
echo "Data: $(date)"
echo

# Função para verificar conectividade básica
check_basic_connectivity() {
    echo "1. TESTANDO CONECTIVIDADE BÁSICA"
    echo "================================="
    
    VMS=(
        "192.168.101.210:aplicacao"
        "192.168.101.211:banco"
        "192.168.101.212:nfs"
        "192.168.101.213:superset"
    )
    
    for vm_info in "${VMS[@]}"; do
        IFS=':' read -r ip name <<< "$vm_info"
        echo -n "  $name ($ip): "
        
        if ping -c 1 -W 2 "$ip" > /dev/null 2>&1; then
            echo "✓ PING OK"
        else
            echo "✗ PING FAIL"
        fi
    done
    echo
}

# Função para verificar MACs
check_macs_from_host() {
    echo "2. VERIFICANDO MACs DO HOST PROXMOX"
    echo "===================================="
    
    # Se tiver acesso SSH ao Proxmox, podemos verificar as VMs
    echo "  Execute no Proxmox para verificar MACs das VMs:"
    echo "  qm config 202 | grep net0"
    echo "  qm config 203 | grep net0"
    echo "  qm config 204 | grep net0"
    echo "  qm config 205 | grep net0"
    echo
}

# Função para verificar ARP
check_arp_table() {
    echo "3. VERIFICANDO TABELA ARP"
    echo "========================="
    
    echo "  Tabela ARP atual:"
    arp -a | grep "192.168.101.21[0-3]" || echo "  Nenhuma entrada encontrada para as VMs"
    echo
}

# Função para verificar DHCP
check_dhcp_issues() {
    echo "4. TESTANDO PROBLEMAS DE DHCP"
    echo "=============================="
    
    echo "  Para testar DHCP, você pode temporariamente:"
    echo "  1. Mudar uma VM para DHCP: ipconfig0 = 'dhcp'"
    echo "  2. Aplicar: terraform apply"
    echo "  3. Verificar se ela pega IP único"
    echo "  4. Reverter para IP estático"
    echo
}

# Função para verificar roteamento
check_routing() {
    echo "5. VERIFICANDO ROTEAMENTO"
    echo "========================="
    
    echo "  Gateway configurado: 192.168.101.1"
    echo -n "  Gateway acessível: "
    
    if ping -c 1 -W 2 192.168.101.1 > /dev/null 2>&1; then
        echo "✓ OK"
    else
        echo "✗ FAIL"
    fi
    
    echo -n "  DNS 8.8.8.8: "
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        echo "✓ OK"
    else
        echo "✗ FAIL"
    fi
    echo
}

# Função para gerar comandos de correção
generate_fix_commands() {
    echo "6. COMANDOS DE CORREÇÃO SUGERIDOS"
    echo "=================================="
    
    echo "  A. Para forçar recriação das VMs:"
    echo "     ./recreate-vms.sh"
    echo
    
    echo "  B. Para verificar configuração do Terraform:"
    echo "     terraform plan"
    echo
    
    echo "  C. Para verificar estado atual:"
    echo "     terraform show | grep -E '(name|ipconfig0|macaddr)'"
    echo
    
    echo "  D. Para conectar via console (se SSH falhar):"
    echo "     # No Proxmox: qm terminal 202 (para VM banco)"
    echo "     # No Proxmox: qm terminal 203 (para VM nfs)"
    echo "     # No Proxmox: qm terminal 204 (para VM superset)"
    echo "     # No Proxmox: qm terminal 205 (para VM aplicacao)"
    echo
    
    echo "  E. Para verificar logs do cloud-init:"
    echo "     ssh root@IP 'tail -f /var/log/cloud-init.log'"
    echo "     ssh root@IP 'cloud-init status'"
    echo
}

# Executar todas as verificações
check_basic_connectivity
check_macs_from_host
check_arp_table
check_dhcp_issues
check_routing
generate_fix_commands

echo "=== FIM DO DIAGNÓSTICO ==="