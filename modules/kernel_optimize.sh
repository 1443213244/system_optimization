#!/bin/bash

optimize_kernel() {
    #超级安全的基础优化
    sudo sed -i '/qdisc\|congestion_control/!d' /etc/sysctl.conf
    echo "net.core.wmem_default =10486760" >> /etc/sysctl.conf
    echo "net.core.wmem_max=26214400" >> /etc/sysctl.conf
    echo "net.core.rmem_default=26214400" >> /etc/sysctl.conf
    echo "net.core.rmem_max=56214400" >> /etc/sysctl.conf
    echo "net.core.netdev_max_backlog = 10000" >> /etc/sysctl.conf
    echo "fs.file-max=1000000" >> /etc/sysctl.conf
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    echo "net.core.rps_sock_flow_entries = 65536" >> /etc/sysctl.conf
    sysctl -p

    ulimit -HSn 500000
    apt install -y sed
    sed -i '/soft nofile/d' /etc/security/limits.conf && echo "* soft nofile 500000" >> /etc/security/limits.conf
    sed -i '/hard nofile/d' /etc/security/limits.conf && echo "* hard nofile 500000" >> /etc/security/limits.conf
    return 0
} 