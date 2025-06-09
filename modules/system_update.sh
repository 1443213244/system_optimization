#!/bin/bash

update_system() {
    log_info "开始系统更新..."
    
    # 更新软件包列表
    apt-get update
    check_status "软件包列表更新成功" "软件包列表更新失败" || return 1
    
    # 升级系统
    apt-get upgrade -y
    check_status "系统升级成功" "系统升级失败" || return 1
    
    # 清理不需要的包
    apt-get autoremove -y
    check_status "清理完成" "清理失败" || return 1
    
    log_info "系统更新完成"
    return 0
} 