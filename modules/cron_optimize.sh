#!/bin/bash
source modules/log.sh

optimize_cron() {
    log_info "开始优化系统定时任务..."
    

    # 添加 GOST 服务重启任务（每48小时）
    log_info "添加 GOST 服务重启任务..."
    (crontab -l 2>/dev/null; echo "0 0 */2 * * systemctl restart gost") | sort - | uniq - | crontab -


    #添加清理内存定时任务（每48小时）
    log_info "添加清理内存定时任务..."
    (crontab -l 2>/dev/null; echo "0 0 */2 * * sync; echo 3 > /proc/sys/vm/drop_caches") | sort - | uniq - | crontab -

    
    
    #添加network_optimize定时任务
    log_info "添加network_optimize定时任务..."
    (crontab -l 2>/dev/null; echo "@reboot sleep 30 &&  /opt/system_optimization/modules/network_optimize.sh") | sort - | uniq - | crontab -
    
    
    #添加firewall_optimize定时任务
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

}

# 添加自定义定时任务
add_cron_task() {
    local schedule="$1"
    local command="$2"
    log_info "添加自定义定时任务..."
    (crontab -l 2>/dev/null; echo "$schedule $command") | sort - | uniq - | crontab -
} 
