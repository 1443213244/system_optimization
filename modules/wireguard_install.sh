#!/bin/bash

install_wireguard() {
    log_info "开始安装 WireGuard..."
    
    # 创建 WireGuard 配置目录
    mkdir -p /etc/wireguard
    
    # 生成 WireGuard 配置
    log_info "配置 WireGuard..."
    cat > /etc/wireguard/wg0.conf << EOF
[Interface]
Address = 172.30.30.1/32
SaveConfig = true
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51468
PrivateKey = sCK+ns1GH0CxBnKgO5v14o+u51xfIrkiCTeT828dJVI=
EOF
    
    # 启用并启动 WireGuard 服务
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0
    check_status "WireGuard 服务启动成功" "WireGuard 服务启动失败" || return 1
    
    log_info "WireGuard 安装完成"
    return 0
}

install_wgrest() {
    log_info "开始安装 wgrest..."
    
    # 下载 wgrest 二进制文件
    log_info "下载 wgrest 二进制文件..."
    curl -L https://github.com/suquant/wgrest/releases/latest/download/wgrest-linux-amd64 -o /usr/bin/wgrest
    check_status "wgrest 二进制文件下载成功" "wgrest 二进制文件下载失败" || return 1
    
    # 设置执行权限
    chmod +x /usr/bin/wgrest
    
    # 下载并安装 webapp
    log_info "下载并安装 webapp..."
    curl -L https://github.com/suquant/wgrest-webapp/releases/latest/download/webapp.tar.gz -o webapp.tar.gz
    check_status "webapp 下载成功" "webapp 下载失败" || return 1
    
    # 创建安装目录
    mkdir -p /var/lib/wgrest/
    chown `whoami` /var/lib/wgrest/
    
    # 解压 webapp
    tar -xzvf webapp.tar.gz -C /var/lib/wgrest/
    rm -f webapp.tar.gz
    
    # 创建 systemd 服务
    log_info "创建 wgrest 服务..."
    cat > /etc/systemd/system/wgrest.service << EOF
[Unit]
Description=wgrest
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Type=simple
User=root
DynamicUser=false
ExecStart=/usr/bin/wgrest --static-auth-token "secret" --listen "0.0.0.0:8001"

[Install]
WantedBy=multi-user.target
EOF
    
    # 启用并启动服务
    systemctl daemon-reload
    systemctl enable wgrest
    systemctl start wgrest
    check_status "wgrest 服务启动成功" "wgrest 服务启动失败" || return 1
    
    log_info "wgrest 安装完成"
    return 0
}

# 创建系统优化脚本
create_optimization_scripts() {
    log_info "创建系统优化脚本..."
    
    # 创建 sysctl 优化脚本
    cat > /usr/local/bin/sysctl.sh << EOF
#!/bin/bash
# 系统参数优化
sysctl -p
EOF
    
    # 创建 MTU 优化脚本
    cat > /usr/local/bin/mtu.sh << EOF
#!/bin/bash
# MTU 优化
ip link set dev eth0 mtu 9000
EOF
    
    # 创建 DNS 优化脚本
    cat > /usr/local/bin/dns.sh << EOF
#!/bin/bash
# DNS 优化
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
EOF
    
    # 设置执行权限
    chmod +x /usr/local/bin/sysctl.sh
    chmod +x /usr/local/bin/mtu.sh
    chmod +x /usr/local/bin/dns.sh
    
    # 添加到启动项
    if [ ! -f /etc/rc.local ]; then
        echo '#!/bin/bash' > /etc/rc.local
        echo 'exit 0' >> /etc/rc.local
        chmod +x /etc/rc.local
    fi
    
    # 添加启动命令
    sed -i '/exit 0/i bash /usr/local/bin/sysctl.sh &' /etc/rc.local
    sed -i '/exit 0/i bash /usr/local/bin/mtu.sh &' /etc/rc.local
    sed -i '/exit 0/i bash /usr/local/bin/dns.sh &' /etc/rc.local
    
    log_info "系统优化脚本创建完成"
    return 0
}

optimize_wireguard() {
    log_info "开始 WireGuard 相关优化..."
    
    # 安装 WireGuard
    install_wireguard || return 1
    
    # 安装 wgrest
    install_wgrest || return 1
    
    # 创建优化脚本
    create_optimization_scripts || return 1
    
    # 执行优化脚本
    bash /usr/local/bin/sysctl.sh &
    bash /usr/local/bin/mtu.sh &
    bash /usr/local/bin/dns.sh &
    
    log_info "WireGuard 相关优化完成"
    return 0
} 
