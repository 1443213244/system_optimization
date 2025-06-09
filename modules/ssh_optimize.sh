#!/bin/bash

optimize_ssh() {
    log_info "开始优化SSH配置..."
    local ssh_config="/etc/ssh/sshd_config"
    
    # 备份原配置文件
    backup_file "$ssh_config"
    
    # 修改SSH配置
    sed -i 's/.*\s*ClientAliveInterval.*/\ClientAliveInterval 30/' "$ssh_config"
    sed -i 's/.*\s*ClientAliveCountMax.*/\ClientAliveCountMax 10/' "$ssh_config"
    
    # 重启SSH服务
    systemctl restart sshd
    check_status "SSH服务重启成功" "SSH服务重启失败" || return 1
    
    # 显示当前SSH连接状态
    log_info "当前SSH连接状态："
    ss -ntlp | grep ssh
    
    log_info "SSH优化完成"
    return 0
} 