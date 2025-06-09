#!/bin/bash

optimize_security() {
    log_info "开始优化系统安全配置..."
    
    # 禁用 root 密码登录
    log_info "禁用 root 密码登录..."
    if [ -f /etc/ssh/sshd_config ]; then
        backup_file "/etc/ssh/sshd_config"
        sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
        systemctl restart sshd
        check_status "SSH root 登录已禁用" "SSH root 登录禁用失败"
    fi
    
    # 禁用密码认证
    log_info "禁用 SSH 密码认证..."
    if [ -f /etc/ssh/sshd_config ]; then
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
        systemctl restart sshd
        check_status "SSH 密码认证已禁用" "SSH 密码认证禁用失败"
    fi
    
    # 设置 SSH 端口
    log_info "修改 SSH 端口为 22222..."
    if [ -f /etc/ssh/sshd_config ]; then
        sed -i 's/#Port 22/Port 22222/g' /etc/ssh/sshd_config
        systemctl restart sshd
        check_status "SSH 端口已修改" "SSH 端口修改失败"
    fi
    
    # 禁用 IPv6
    log_info "禁用 IPv6..."
    if [ -f /etc/sysctl.conf ]; then
        backup_file "/etc/sysctl.conf"
        cat >> /etc/sysctl.conf << EOF
# 禁用 IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
        sysctl -p
        check_status "IPv6 已禁用" "IPv6 禁用失败"
    fi
    
    # 设置系统时区
    log_info "设置系统时区为 Asia/Shanghai..."
    timedatectl set-timezone Asia/Shanghai
    check_status "系统时区已设置" "系统时区设置失败"
    
    # 安装并配置 fail2ban
    log_info "安装并配置 fail2ban..."
    apt-get install -y fail2ban
    if [ $? -eq 0 ]; then
        # 配置 fail2ban
        cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = 22222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF
        systemctl restart fail2ban
        check_status "fail2ban 已配置并启动" "fail2ban 配置失败"
    else
        log_error "fail2ban 安装失败"
    fi
    
    # 设置系统资源限制
    log_info "设置系统资源限制..."
    if [ -f /etc/security/limits.conf ]; then
        backup_file "/etc/security/limits.conf"
        cat >> /etc/security/limits.conf << EOF
# 系统资源限制
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOF
        check_status "系统资源限制已设置" "系统资源限制设置失败"
    fi
    
    # 设置系统内核参数
    log_info "设置系统内核参数..."
    if [ -f /etc/sysctl.conf ]; then
        cat >> /etc/sysctl.conf << EOF
# 系统安全参数
kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_tw_buckets = 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 87380 16777216
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = bbr
EOF
        sysctl -p
        check_status "系统内核参数已设置" "系统内核参数设置失败"
    fi
    
    log_info "系统安全优化完成"
    return 0
} 