#!/bin/bash

# 基本配置
BACKUP_DIR="/var/backups/system_optimization"
LOG_FILE="/var/log/system_optimization.log"
MODULES_DIR="modules"

# 错误处理函数
handle_error() {
    local exit_code=$1
    local error_message=$2
    log "错误: $error_message (退出代码: $exit_code)"
    exit "$exit_code"
}

# 日志函数
log() {
    local message=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# 检查模块是否存在
check_modules() {
    local required_modules=(
        "tools_install.sh"
        "ssh_optimize.sh"
        "network_optimize.sh"
        "firewall_optimize.sh"
        "cron_optimize.sh"
        "wireguard_install.sh"
        "log_optimize.sh"
        "kernel_optimize.sh"
        "gost_install.sh"
    )

    for module in "${required_modules[@]}"; do
        if [ ! -f "$MODULES_DIR/$module" ]; then
            handle_error 1 "缺少必要模块: $module"
        fi
    done
}

# 检查系统要求
check_system() {
    # 检查是否为 Debian 系统
    if [ ! -f /etc/debian_version ]; then
        handle_error 1 "此脚本仅支持 Debian 系统"
    fi

    # 检查 Debian 版本
    DEBIAN_VERSION=$(cat /etc/debian_version)
    log "检测到 Debian 版本: $DEBIAN_VERSION"

    # 检查系统架构
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
        log "警告: 当前系统架构 $ARCH 可能不完全支持所有优化"
    fi

    # 检查内存大小
    MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$MEM_TOTAL" -lt 1024 ]; then
        log "警告: 系统内存小于 1GB，某些优化可能不适用"
    fi

    # 检查磁盘空间
    DISK_SPACE=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "${DISK_SPACE%.*}" -lt 10 ]; then
        log "警告: 系统磁盘空间小于 10GB，建议清理后再运行优化"
    fi

    return 0
}

# 检查并创建必要的目录
setup_directories() {
    local dirs=("$BACKUP_DIR" "/var/log/system_optimization")
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            if ! mkdir -p "$dir"; then
                handle_error 1 "无法创建目录: $dir"
            fi
            if ! chmod 755 "$dir"; then
                handle_error 1 "无法设置目录权限: $dir"
            fi
            log "创建目录: $dir"
        fi
    done
}

# 清理函数
cleanup() {
    log "清理临时文件..."
    apt-get clean
    apt-get autoremove -y
    rm -rf /tmp/*
    log "清理完成"
}

# 导入模块
check_modules
source "$MODULES_DIR/tools_install.sh"
source "$MODULES_DIR/ssh_optimize.sh"
source "$MODULES_DIR/network_optimize.sh"
source "$MODULES_DIR/firewall_optimize.sh"
source "$MODULES_DIR/cron_optimize.sh"
source "$MODULES_DIR/wireguard_install.sh"
source "$MODULES_DIR/log_optimize.sh"
source "$MODULES_DIR/kernel_optimize.sh"
source "$MODULES_DIR/gost_install.sh"

# 主函数
main() {
    # 设置错误处理
    set -e
    trap 'handle_error $? "发生未预期的错误"' ERR

    # 检查 root 权限
    if [ "$(id -u)" != "0" ]; then
        handle_error 1 "需要 root 权限运行此脚本"
    fi

    # 检查系统要求
    check_system

    # 设置目录
    setup_directories

    log "开始系统优化..."
    
    # 安装工具
    install_tools || handle_error 1 "工具安装失败"
    log "✓ 工具安装完成"
    
    # 优化 SSH
    optimize_ssh || handle_error 1 "SSH 优化失败"
    log "✓ SSH 优化完成"
    
    # 优化网络
    optimize_network || handle_error 1 "网络优化失败"
    log "✓ 网络优化完成"

    # 优化内核参数
    optimize_kernel || handle_error 1 "内核优化失败"
    log "✓ 内核优化完成"
    
    # 优化防火墙
    optimize_firewall || handle_error 1 "防火墙优化失败"
    log "✓ 防火墙优化完成"
    
    # 优化定时任务
    optimize_cron || handle_error 1 "定时任务优化失败"
    log "✓ 定时任务优化完成"

    install_gost || handle_error 1 "Gost 安装失败"
    log "✓ Gost 安装完成"
    
    # 安装 WireGuard
    install_wireguard || handle_error 1 "WireGuard 安装失败"
    log "✓ WireGuard 安装完成"

    # 优化日志
    log_optimize || handle_error 1 "日志优化失败"
    log "✓ 日志优化完成"
    
    # 清理临时文件
    cleanup
    
    log "系统优化完成"
    return 0
}

# 执行主函数
main "$@" 
