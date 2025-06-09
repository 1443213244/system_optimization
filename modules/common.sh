#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[INFO] ${timestamp} - ${message}${NC}"
    echo "[INFO] ${timestamp} - ${message}" >> "${LOGS_DIR}/system_optimization.log"
}

log_warn() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[WARN] ${timestamp} - ${message}${NC}"
    echo "[WARN] ${timestamp} - ${message}" >> "${LOGS_DIR}/system_optimization.log"
}

log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[ERROR] ${timestamp} - ${message}${NC}"
    echo "[ERROR] ${timestamp} - ${message}" >> "${LOGS_DIR}/system_optimization.log"
}

# 检查命令执行状态
check_status() {
    if [ $? -eq 0 ]; then
        log_info "$1"
        return 0
    else
        log_error "$2"
        return 1
    fi
}

# 备份文件
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
        check_status "已备份文件: $file" "备份文件失败: $file"
    fi
} 