#!/bin/bash

# 基本配置
BACKUP_DIR="/var/backups/system_optimization"
LOG_FILE="/var/log/system_optimization.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查模块文件是否存在并可执行
check_module() {
    local module="$1"
    if [ ! -f "$module" ]; then
        log "错误: 模块文件 $module 不存在"
        return 1
    fi
    if [ ! -x "$module" ]; then
        log "警告: 模块文件 $module 没有执行权限，尝试添加权限"
        chmod +x "$module"
    fi
    return 0
}

# 导入模块
MODULES=(
    "modules/tools_install.sh"
    "modules/ssh_optimize.sh"
    "modules/network_optimize.sh"
    "modules/firewall_optimize.sh"
    "modules/cron_optimize.sh"
    "modules/wireguard_install.sh"
    "modules/log_optimize.sh"
    "modules/kernel_optimize.sh"
)

# 确保所有模块都被正确加载
for module in "${MODULES[@]}"; do
    if check_module "$module"; then
        log "正在加载模块: $module"
        # 使用 source 命令加载模块，并检查是否成功
        if ! source "$module"; then
            log "错误: 无法加载模块 $module"
            exit 1
        fi
        # 验证模块中的主要函数是否存在
        module_name=$(basename "$module" .sh)
        if ! type -t "${module_name//_/-}" >/dev/null 2>&1; then
            log "错误: 模块 $module 中的主要函数未定义"
            exit 1
        fi
    else
        exit 1
    fi
done

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
    # mkdir -p "$BACKUP_DIR"
    # log "✓ 备份目录创建成功"
    
    log "开始系统优化..."
    
    # 安装工具
    if ! install-tools; then
        log "错误: 工具安装失败"
        exit 1
    fi
    log "✓ 工具安装完成"
    
    # 优化 SSH
    if ! optimize-ssh; then
        log "错误: SSH 优化失败"
        exit 1
    fi
    log "✓ SSH 优化完成"
    
    # 优化网络
    if ! optimize-network; then
        log "错误: 网络优化失败"
        exit 1
    fi
    log "✓ 网络优化完成"
    
    # 优化防火墙
    if ! optimize-firewall; then
        log "错误: 防火墙优化失败"
        exit 1
    fi
    log "✓ 防火墙优化完成"
    
    # 优化定时任务
    if ! optimize-cron; then
        log "错误: 定时任务优化失败"
        exit 1
    fi
    log "✓ 定时任务优化完成"
    
    # 安装 WireGuard
    if ! install-wireguard; then
        log "错误: WireGuard 安装失败"
        exit 1
    fi
    log "✓ WireGuard 安装完成"
    
    # 优化安全设置
    #optimize_security
    #log "✓ 安全优化完成"
    
    # 优化内核参数
    if ! optimize-kernel; then
        log "错误: 内核优化失败"
        exit 1
    fi
    log "✓ 内核优化完成"

    # 优化日志
    if ! log-optimize; then
        log "错误: 日志优化失败"
        exit 1
    fi
    log "✓ 日志优化完成"
    
    log "系统优化完成"
    return 0
}

# 执行主函数
main "$@" 
