#!/bin/bash

optimize_network() {
    log_info "开始优化网卡参数..."
    local sysctl_conf="/etc/sysctl.conf"
    
    # 备份原配置文件
    backup_file "$sysctl_conf"
    
    # 获取默认网卡接口
    local iface=$(ip route get 223.5.5.5 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
    log_info "检测到默认网卡接口: $iface"
    
    # 优化网卡特性
    log_info "优化网卡特性..."
    for opt in \
        tx-checksumming \
        tx-checksum-ip-generic \
        scatter-gather \
        tx-scatter-gather \
        generic-segmentation-offload \
        generic-receive-offload \
        tcp-segmentation-offload \
        tx-tcp-segmentation \
        tx-tcp-ecn-segmentation \
        tx-tcp6-segmentation \
        udp-fragmentation-offload \
        tx-nocache-copy \
        rx-gro-hw \
        rx-gro-list \
        rx-udp-gro-forwarding; do
        ethtool -K "$iface" "$opt" on
        check_status "启用 $opt 成功" "启用 $opt 失败"
    done
    
    # 显示网卡当前配置
    log_info "当前网卡配置："
    ethtool -k "$iface" | grep -v fixed
    
    # 添加网卡优化参数到 sysctl.conf
    log_info "添加网卡优化参数到系统配置..."
    cat >> "$sysctl_conf" << EOF
# 网卡优化参数
net.core.wmem_default = 10486760
net.core.wmem_max = 26214400
net.core.rmem_default = 26214400
net.core.rmem_max = 56214400
net.core.netdev_max_backlog = 10000
net.core.rps_sock_flow_entries = 65536
net.ipv4.ip_forward = 1
EOF
    
    # 应用配置
    sysctl -p
    check_status "网卡参数应用成功" "网卡参数应用失败" || return 1
    
    # 配置 TC 队列规则
    log_info "配置 TC 队列规则..."
    tc qdisc replace dev "$iface" root pfifo_fast
    check_status "TC 队列规则配置成功" "TC 队列规则配置失败" || return 1
    
    # 创建开机启动脚本
    log_info "创建开机启动脚本..."
    cat > /usr/local/bin/tc-optimize.sh << EOF
#!/bin/bash
# TC 队列规则优化脚本
iface=\$(ip route get 223.5.5.5 | awk '{for(i=1;i<=NF;i++) if(\$i=="dev") print \$(i+1)}')
tc qdisc replace dev "\$iface" root pfifo_fast
EOF
    
    # 设置执行权限
    chmod +x /usr/local/bin/tc-optimize.sh
    
    # 添加到开机启动
    if [ ! -f /etc/rc.local ]; then
        echo '#!/bin/bash' > /etc/rc.local
        echo 'exit 0' >> /etc/rc.local
        chmod +x /etc/rc.local
    fi
    
    # 添加启动命令（确保不重复添加）
    if ! grep -q "tc-optimize.sh" /etc/rc.local; then
        sed -i '/exit 0/i bash /usr/local/bin/tc-optimize.sh &' /etc/rc.local
    fi
    
    log_info "网卡优化完成"
    return 0
} 