#!/bin/bash

# 日志函数
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查状态函数
check_status() {
    if [ $? -eq 0 ]; then
        log_info "✓ $1"
        return 0
    else
        log_info "✗ $2"
        return 1
    fi
}

system_update() {
    log_info "开始系统更新..."
    
    # 更新软件包列表
    apt-get update
    check_status "软件包列表更新成功" "软件包列表更新失败" || return 1
    
    # 升级系统
    #apt-get upgrade -y
    #check_status "系统升级成功" "系统升级失败" || return 1
    
    # 清理不需要的包
    apt-get autoremove -y
    check_status "清理完成" "清理失败" || return 1
    
    log_info "系统更新完成"
    return 0
} 
