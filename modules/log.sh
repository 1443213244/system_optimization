#!/bin/bash

# 导入配置
source config/config.sh

# 创建日志目录
mkdir -p "${SYSTEM_CONFIG[LOG_DIR]}"

# 日志文件
LOG_FILE="${SYSTEM_CONFIG[LOG_DIR]}/system_optimization.log"

# 日志级别
declare -A LOG_LEVELS=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARN"]=2
    ["ERROR"]=3
)

# 当前日志级别
CURRENT_LOG_LEVEL="${LOG_CONFIG[LOG_LEVEL]}"

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"${LOG_CONFIG[LOG_FORMAT]}")
    
    # 检查日志级别
    if [ -n "${LOG_LEVELS[$level]}" ] && [ -n "${LOG_LEVELS[$CURRENT_LOG_LEVEL]}" ]; then
        if [ "${LOG_LEVELS[$level]}" -ge "${LOG_LEVELS[$CURRENT_LOG_LEVEL]}" ]; then
            echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
        fi
    else
        echo "[$timestamp] [ERROR] 无效的日志级别: $level 或 $CURRENT_LOG_LEVEL" | tee -a "$LOG_FILE"
    fi
}

# 日志级别函数
log_debug() {
    log "DEBUG" "$1"
}

log_info() {
    log "INFO" "$1"
}

log_warn() {
    log "WARN" "$1"
}

log_error() {
    log "ERROR" "$1"
}

# 检查状态函数
check_status() {
    local success_msg="$1"
    local error_msg="$2"
    local status=$?
    
    if [ $status -eq 0 ]; then
        log_info "$success_msg"
        return 0
    else
        log_error "$error_msg (错误码: $status)"
        return 1
    fi
}

# 备份文件函数
backup_file() {
    local file="$1"
    local backup_dir="${SYSTEM_CONFIG[BACKUP_DIR]}/$(date +%Y%m%d)"
    local backup_file="$backup_dir/$(basename "$file").$(date +%Y%m%d%H%M%S)"
    
    # 创建备份目录
    mkdir -p "$backup_dir"
    
    # 备份文件
    if [ -f "$file" ]; then
        cp "$file" "$backup_file"
        log_info "文件 $file 已备份到 $backup_file"
        return 0
    else
        log_warn "文件 $file 不存在，跳过备份"
        return 1
    fi
}

# 日志轮转函数
rotate_logs() {
    local log_dir="${SYSTEM_CONFIG[LOG_DIR]}"
    local max_size="${LOG_CONFIG[LOG_MAX_SIZE]}"
    local retention_days="${LOG_CONFIG[LOG_RETENTION_DAYS]}"
    
    # 检查日志大小
    if [ -f "$LOG_FILE" ]; then
        local size=$(stat -c%s "$LOG_FILE")
        if [ $size -gt $(numfmt --from=iec $max_size) ]; then
            mv "$LOG_FILE" "$LOG_FILE.$(date +%Y%m%d%H%M%S)"
            log_info "日志文件已轮转"
        fi
    fi
    
    # 删除旧日志
    find "$log_dir" -name "*.log.*" -type f -mtime +$retention_days -delete
}

# 清理日志函数
cleanup_logs() {
    local log_dir="${SYSTEM_CONFIG[LOG_DIR]}"
    local retention_days="${LOG_CONFIG[LOG_RETENTION_DAYS]}"
    
    # 删除超过保留期的日志
    find "$log_dir" -name "*.log*" -type f -mtime +$retention_days -delete
    log_info "已清理超过 ${retention_days} 天的日志文件"
}

# 设置日志级别函数
set_log_level() {
    local level="$1"
    if [ -n "${LOG_LEVELS[$level]}" ]; then
        CURRENT_LOG_LEVEL="$level"
        log_info "日志级别已设置为 $level"
    else
        log_error "无效的日志级别: $level"
        return 1
    fi
}

# 获取日志级别函数
get_log_level() {
    echo "$CURRENT_LOG_LEVEL"
}

# 导出函数
export -f log_debug
export -f log_info
export -f log_warn
export -f log_error
export -f check_status
export -f backup_file
export -f rotate_logs
export -f cleanup_logs
export -f set_log_level
export -f get_log_level 