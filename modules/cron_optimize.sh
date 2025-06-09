#!/bin/bash

optimize_cron() {
    log_info "开始优化系统定时任务..."
    
    # 添加系统优化定时任务
    log_info "添加系统优化定时任务..."
    (crontab -l 2>/dev/null; echo '0 */12 * * * sed -i "/net.ipv4.tcp_slow_start_after_idle/d" /etc/sysctl.conf; sysctl -p') | sort - | uniq - | crontab -
    check_status "系统优化定时任务已添加" "系统优化定时任务添加失败"
    
    # 添加 SSH 服务重启任务（开机后5秒）
    log_info "添加 SSH 服务重启任务..."
    (crontab -l 2>/dev/null; echo "@reboot sleep 5 && systemctl restart sshd") | sort - | uniq - | crontab -
    check_status "SSH 服务重启任务已添加" "SSH 服务重启任务添加失败"
    
    # 添加 GOST 服务重启任务（每小时）
    log_info "添加 GOST 服务重启任务..."
    (crontab -l 2>/dev/null; echo "0 * * * * systemctl restart gost") | sort - | uniq - | crontab -
    check_status "GOST 服务重启任务已添加" "GOST 服务重启任务添加失败"
    
    # 显示当前定时任务
    log_info "当前系统定时任务列表："
    crontab -l
    
    log_info "定时任务优化完成"
    return 0
}

# 删除指定定时任务
remove_cron_task() {
    local task_pattern="$1"
    log_info "删除包含 '$task_pattern' 的定时任务..."
    crontab -l | grep -v "$task_pattern" | crontab -
    check_status "定时任务已删除" "定时任务删除失败"
}

# 添加自定义定时任务
add_cron_task() {
    local schedule="$1"
    local command="$2"
    log_info "添加自定义定时任务..."
    (crontab -l 2>/dev/null; echo "$schedule $command") | sort - | uniq - | crontab -
    check_status "自定义定时任务已添加" "自定义定时任务添加失败"
} 