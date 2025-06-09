#!/bin/bash

# 导入日志模块
source modules/log.sh

# 错误代码定义
declare -A ERROR_CODES=(
    ["SUCCESS"]=0
    ["INVALID_ARGUMENT"]=1
    ["PERMISSION_DENIED"]=2
    ["FILE_NOT_FOUND"]=3
    ["NETWORK_ERROR"]=4
    ["SERVICE_ERROR"]=5
    ["CONFIG_ERROR"]=6
    ["INSTALL_ERROR"]=7
    ["BACKUP_ERROR"]=8
    ["RESTORE_ERROR"]=9
    ["UNKNOWN_ERROR"]=255
)

# 错误处理函数
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local error_context="$3"
    
    # 记录错误
    log_error "错误代码: $error_code, 消息: $error_message, 上下文: $error_context"
    
    # 根据错误代码执行相应的处理
    case $error_code in
        ${ERROR_CODES[INVALID_ARGUMENT]})
            log_error "参数错误: $error_message"
            ;;
        ${ERROR_CODES[PERMISSION_DENIED]})
            log_error "权限不足: $error_message"
            ;;
        ${ERROR_CODES[FILE_NOT_FOUND]})
            log_error "文件不存在: $error_message"
            ;;
        ${ERROR_CODES[NETWORK_ERROR]})
            log_error "网络错误: $error_message"
            ;;
        ${ERROR_CODES[SERVICE_ERROR]})
            log_error "服务错误: $error_message"
            ;;
        ${ERROR_CODES[CONFIG_ERROR]})
            log_error "配置错误: $error_message"
            ;;
        ${ERROR_CODES[INSTALL_ERROR]})
            log_error "安装错误: $error_message"
            ;;
        ${ERROR_CODES[BACKUP_ERROR]})
            log_error "备份错误: $error_message"
            ;;
        ${ERROR_CODES[RESTORE_ERROR]})
            log_error "恢复错误: $error_message"
            ;;
        *)
            log_error "未知错误: $error_message"
            ;;
    esac
    
    # 返回错误代码
    return $error_code
}

# 检查命令执行结果
check_command() {
    local command="$1"
    local error_message="$2"
    local error_context="$3"
    
    # 执行命令
    eval "$command"
    local status=$?
    
    # 检查执行结果
    if [ $status -ne 0 ]; then
        handle_error $status "$error_message" "$error_context"
        return $status
    fi
    
    return 0
}

# 检查文件是否存在
check_file() {
    local file="$1"
    local error_message="$2"
    local error_context="$3"
    
    if [ ! -f "$file" ]; then
        handle_error ${ERROR_CODES[FILE_NOT_FOUND]} "$error_message" "$error_context"
        return ${ERROR_CODES[FILE_NOT_FOUND]}
    fi
    
    return 0
}

# 检查目录是否存在
check_directory() {
    local directory="$1"
    local error_message="$2"
    local error_context="$3"
    
    if [ ! -d "$directory" ]; then
        handle_error ${ERROR_CODES[FILE_NOT_FOUND]} "$error_message" "$error_context"
        return ${ERROR_CODES[FILE_NOT_FOUND]}
    fi
    
    return 0
}

# 检查权限
check_permission() {
    local file="$1"
    local error_message="$2"
    local error_context="$3"
    
    if [ ! -w "$file" ]; then
        handle_error ${ERROR_CODES[PERMISSION_DENIED]} "$error_message" "$error_context"
        return ${ERROR_CODES[PERMISSION_DENIED]}
    fi
    
    return 0
}

# 检查网络连接
check_network() {
    local host="$1"
    local error_message="$2"
    local error_context="$3"
    
    if ! ping -c 1 "$host" >/dev/null 2>&1; then
        handle_error ${ERROR_CODES[NETWORK_ERROR]} "$error_message" "$error_context"
        return ${ERROR_CODES[NETWORK_ERROR]}
    fi
    
    return 0
}

# 检查服务状态
check_service() {
    local service="$1"
    local error_message="$2"
    local error_context="$3"
    
    if ! systemctl is-active --quiet "$service"; then
        handle_error ${ERROR_CODES[SERVICE_ERROR]} "$error_message" "$error_context"
        return ${ERROR_CODES[SERVICE_ERROR]}
    fi
    
    return 0
}

# 导出函数
export -f handle_error
export -f check_command
export -f check_file
export -f check_directory
export -f check_permission
export -f check_network
export -f check_service 