#!/bin/bash

# 工具列表
TOOLS=(
    # 网络工具
    "net-tools"
    "iproute2"
    "curl"
    "wget"
    "dnsutils"
    
    # 系统工具
    "htop"
    "iotop"
    "sysstat"
    "vim"
    "git"
    
    # 安全工具
    "fail2ban"
    "ufw"
    "iptables"
    
    # 监控工具
    "prometheus-node-exporter"
    "prometheus"
    
    # VPN 工具
    "wireguard-tools"
)

# 安装工具
install_tools() {
    echo "正在更新软件包列表..."
    apt-get update
    
    echo "正在安装工具..."
    for tool in "${TOOLS[@]}"; do
        echo "安装 $tool..."
        apt-get install -y "$tool"
    done
    
    echo "清理不需要的包..."
    apt-get autoremove -y
    apt-get clean
} 