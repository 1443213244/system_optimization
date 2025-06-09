#!/bin/bash

# 安装工具
install_tools() {
    echo "正在安装工具..."
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    apt-get install net-tools iproute2 curl wget iftop wireguard-tools iptables speedtest mtr iperf3 -y
    
    echo "清理不需要的包..."
    apt-get autoremove -y
    apt-get clean
} 
