#!/bin/bash

# 导入日志和错误处理模块
source modules/log.sh
source modules/error_handler.sh

# 检查系统要求
check_system_requirements() {
    log_info "检查系统要求..."
    
    # 检查操作系统
    if [ -f /etc/debian_version ]; then
        local debian_version=$(cat /etc/debian_version)
        log_info "检测到 Debian 版本: $debian_version"
    else
        handle_error ${ERROR_CODES[CONFIG_ERROR]} "不支持的操作系统" "系统检查"
        return ${ERROR_CODES[CONFIG_ERROR]}
    fi
    
    # 检查内核版本
    local kernel_version=$(uname -r)
    log_info "内核版本: $kernel_version"
    
    # 检查内存
    local total_mem=$(free -m | awk '/^Mem:/{print $2}')
    if [ $total_mem -lt 1024 ]; then
        log_warn "系统内存小于 1GB，可能会影响性能"
    fi
    
    # 检查磁盘空间
    local free_space=$(df -m / | awk 'NR==2 {print $4}')
    if [ $free_space -lt 5120 ]; then
        log_warn "根分区可用空间小于 5GB，建议清理"
    fi
    
    return 0
}

# 检查必需的命令
check_required_commands() {
    log_info "检查必需的命令..."
    
    local required_commands=(
        "apt-get"
        "systemctl"
        "ip"
        "ping"
        "curl"
        "wget"
        "grep"
        "sed"
        "awk"
    )
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            handle_error ${ERROR_CODES[CONFIG_ERROR]} "缺少必需命令: $cmd" "命令检查"
            return ${ERROR_CODES[CONFIG_ERROR]}
        fi
    done
    
    return 0
}

# 检查网络连接
check_network_connectivity() {
    log_info "检查网络连接..."
    
    # 检查 DNS 解析
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        log_warn "无法连接到 Google，DNS 可能有问题"
    fi
    
    # 检查软件源连接
    if ! ping -c 1 deb.debian.org >/dev/null 2>&1; then
        handle_error ${ERROR_CODES[NETWORK_ERROR]} "无法连接到 Debian 软件源" "网络检查"
        return ${ERROR_CODES[NETWORK_ERROR]}
    fi
    
    return 0
}

# 检查系统服务
check_system_services() {
    log_info "检查系统服务..."
    
    local required_services=(
        "systemd"
        "network"
        "sshd"
    )
    
    for service in "${required_services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            handle_error ${ERROR_CODES[SERVICE_ERROR]} "服务未运行: $service" "服务检查"
            return ${ERROR_CODES[SERVICE_ERROR]}
        fi
    done
    
    return 0
}

# 检查文件系统权限
check_filesystem_permissions() {
    log_info "检查文件系统权限..."
    
    local critical_paths=(
        "/etc"
        "/var/log"
        "/usr/local"
    )
    
    for path in "${critical_paths[@]}"; do
        if [ ! -w "$path" ]; then
            handle_error ${ERROR_CODES[PERMISSION_DENIED]} "目录不可写: $path" "权限检查"
            return ${ERROR_CODES[PERMISSION_DENIED]}
        fi
    done
    
    return 0
}

# 执行所有检查
run_all_checks() {
    log_info "开始系统依赖检查..."
    
    # 执行各项检查
    check_system_requirements || return $?
    check_required_commands || return $?
    check_network_connectivity || return $?
    check_system_services || return $?
    check_filesystem_permissions || return $?
    
    log_info "所有依赖检查通过"
    return 0
}

# 导出函数
export -f run_all_checks 