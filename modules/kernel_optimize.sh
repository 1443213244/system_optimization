#!/bin/bash

optimize_kernel() {
    log_info "开始优化内核参数..."
    local sysctl_conf="/etc/sysctl.conf"
    
    # 备份原配置文件
    backup_file "$sysctl_conf"
    
    # 清理旧的qdisc和congestion_control配置
    sed -i '/qdisc\|congestion_control/!d' "$sysctl_conf"
    
    # 添加内核优化参数
    cat >> "$sysctl_conf" << EOF
# 内核优化参数
fs.file-max = 1000000
net.core.wmem_default = 10486760
net.core.wmem_max = 26214400
net.core.rmem_default = 26214400
net.core.rmem_max = 56214400
net.core.netdev_max_backlog = 10000
net.ipv4.ip_forward = 1
net.core.rps_sock_flow_entries = 65536
EOF
    
    # 应用配置
    sysctl -p
    check_status "内核参数应用成功" "内核参数应用失败" || return 1
    
    # 设置系统限制
    log_info "设置系统限制..."
    ulimit -HSn 500000
    
    # 更新系统限制配置文件
    sed -i '/soft nofile/d' /etc/security/limits.conf
    sed -i '/hard nofile/d' /etc/security/limits.conf
    echo "* soft nofile 500000" >> /etc/security/limits.conf
    echo "* hard nofile 500000" >> /etc/security/limits.conf
    
    # 优化日志系统
    log_info "优化日志系统..."
    
    # 配置 systemd-journald
    cat > /etc/systemd/journald.conf << EOF
[Journal]
Storage=none
RuntimeMaxUse=0
SystemMaxUse=50M
EOF
    
    # 重启 journald 并清理日志
    systemctl restart systemd-journald
    journalctl --vacuum-size=50M
    
    # 禁用 rsyslog
    if systemctl is-active --quiet rsyslog; then
        log_info "禁用 rsyslog..."
        systemctl stop rsyslog
        systemctl disable rsyslog
        systemctl mask rsyslog
    fi
    
    log_info "内核优化完成"
    return 0
} 