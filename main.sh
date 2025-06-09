#!/bin/bash

# 基本配置
BACKUP_DIR="/var/backups/system_optimization"
LOG_FILE="/var/log/system_optimization.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查函数
check() {
    if [ $? -eq 0 ]; then
        log "✓ $1"
    else
        log "✗ $2"
        exit 1
    fi
}

# 导入模块
source modules/tools_install.sh
source modules/system_update.sh
source modules/ssh_optimize.sh
source modules/network_optimize.sh
source modules/firewall_optimize.sh
source modules/cron_optimize.sh
source modules/wireguard_install.sh
source modules/security_optimize.sh
source modules/kernel_optimize.sh

# 主函数
main() {
    # 检查 root 权限
    if [ "$(id -u)" != "0" ]; then
        log "错误: 需要 root 权限运行此脚本"
        exit 1
    fi
    
    # 检查系统类型
    if [ ! -f /etc/debian_version ]; then
        log "错误: 此脚本仅支持 Debian 系统"
        exit 1
    fi
    
    # 创建备份目录
    mkdir -p "$BACKUP_DIR"
    check "备份目录创建成功" "备份目录创建失败"
    
    log "开始系统优化..."
    
    # 执行系统更新
    system_update
    check "系统更新成功" "系统更新失败"
    
    # 安装工具
    install_tools
    check "工具安装成功" "工具安装失败"
    
    # 优化 SSH
    optimize_ssh
    check "SSH 优化成功" "SSH 优化失败"
    
    # 优化网络
    optimize_network
    check "网络优化成功" "网络优化失败"
    
    # 优化防火墙
    optimize_firewall
    check "防火墙优化成功" "防火墙优化失败"
    
    # 优化定时任务
    optimize_cron
    check "定时任务优化成功" "定时任务优化失败"
    
    # 安装 WireGuard
    install_wireguard
    check "WireGuard 安装成功" "WireGuard 安装失败"
    
    # 优化安全设置
    optimize_security
    check "安全优化成功" "安全优化失败"
    
    # 优化内核参数
    optimize_kernel
    check "内核优化成功" "内核优化失败"
    
    log "系统优化完成"
    return 0
}

# 执行主函数
main "$@" 