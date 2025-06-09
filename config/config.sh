#!/bin/bash

# 系统配置
declare -A SYSTEM_CONFIG
SYSTEM_CONFIG=(
    ["TIMEZONE"]="Asia/Shanghai"
    ["BACKUP_DIR"]="/var/backups/system_optimization"
    ["LOG_DIR"]="/var/log/system_optimization"
)

# SSH 配置
declare -A SSH_CONFIG
SSH_CONFIG=(
    ["PORT"]="22"
    ["PERMIT_ROOT_LOGIN"]="no"
    ["PASSWORD_AUTHENTICATION"]="no"
    ["CLIENT_ALIVE_INTERVAL"]="300"
    ["CLIENT_ALIVE_COUNT_MAX"]="2"
    ["MAX_AUTH_TRIES"]="3"
    ["MAX_SESSIONS"]="10"
    ["LOGIN_GRACE_TIME"]="30"
)

# 网络配置
NETWORK_CONFIG=(
    ["TCP_CONGESTION_CONTROL"]="bbr"
    ["TCP_FASTOPEN"]="3"
    ["TCP_SLOW_START_AFTER_IDLE"]="0"
    ["TCP_NOTSENT_LOWAT"]="16384"
    ["TCP_FIN_TIMEOUT"]="15"
    ["TCP_KEEPALIVE_TIME"]="300"
    ["TCP_KEEPALIVE_INTVL"]="15"
    ["TCP_KEEPALIVE_PROBES"]="5"
    ["TCP_MAX_SYN_BACKLOG"]="8192"
    ["TCP_SYNCOOKIES"]="1"
    ["TCP_TIMESTAMPS"]="1"
    ["TCP_WINDOW_SCALING"]="1"
    ["TCP_SACK"]="1"
    ["TCP_DSACK"]="1"
    ["TCP_FACK"]="1"
    ["TCP_ECN"]="2"
    ["TCP_FRTO"]="2"
    ["TCP_LOW_LATENCY"]="1"
    ["TCP_ADV_WIN_SCALE"]="1"
    ["TCP_APP_WIN"]="31"
    ["TCP_BASE_MSS"]="1024"
    ["TCP_MAX_TW_BUCKETS"]="2000000"
    ["TCP_TW_RECYCLE"]="0"
    ["TCP_ABORT_ON_OVERFLOW"]="0"
    ["TCP_STDURG"]="0"
    ["TCP_RFC1337"]="1"
    ["TCP_MAX_ORPHANS"]="3276800"
    ["TCP_ORPHAN_RETRIES"]="3"
    ["TCP_REORDERING"]="3"
    ["TCP_RETRIES1"]="3"
    ["TCP_RETRIES2"]="15"
    ["TCP_SYN_RETRIES"]="5"
    ["TCP_SYNACK_RETRIES"]="5"
    ["TCP_CHALLENGE_ACK_LIMIT"]="1000"
    ["TCP_MIN_TSO_SEGS"]="2"
    ["TCP_MIN_RTT_WLEN"]="300"
    ["TCP_MODERATE_RCVBUF"]="1"
    ["TCP_NO_METRICS_SAVE"]="1"
    ["TCP_RECOVERY"]="1"
    ["TCP_RETRANS_COLLAPSE"]="0"
    ["TCP_WORKAROUND_SIGNED_WINDOWS"]="0"
)

# 防火墙配置
FIREWALL_CONFIG=(
    ["DEFAULT_POLICY"]="DROP"
    ["ALLOWED_PORTS"]="22,80,443,51820"
    ["ALLOWED_PROTOCOLS"]="tcp,udp,icmp"
    ["MAX_CONNECTIONS"]="100"
    ["CONNECTION_RATE"]="50"
    ["BURST_RATE"]="25"
)

# 安全配置
SECURITY_CONFIG=(
    ["FAIL2BAN_ENABLED"]="true"
    ["FAIL2BAN_MAXRETRY"]="3"
    ["FAIL2BAN_BANTIME"]="3600"
    ["FAIL2BAN_FINDTIME"]="600"
    ["DISABLE_IPV6"]="false"
    ["SYSRQ_DISABLED"]="true"
    ["CORE_DUMPS_DISABLED"]="true"
)

# WireGuard 配置
WIREGUARD_CONFIG=(
    ["INTERFACE"]="wg0"
    ["PORT"]="51820"
    ["NETWORK"]="10.0.0.0/24"
    ["SERVER_IP"]="10.0.0.1"
    ["DNS"]="8.8.8.8,8.8.4.4"
    ["PERSISTENT_KEEPALIVE"]="25"
)

# 定时任务配置
CRON_CONFIG=(
    ["SYSTEM_UPDATE_TIME"]="0 3 * * 0"
    ["LOG_ROTATE_TIME"]="0 2 * * *"
    ["SYSTEM_BACKUP_TIME"]="0 2 * * 1"
    ["SECURITY_SCAN_TIME"]="0 1 * * *"
    ["NETWORK_MONITOR_INTERVAL"]="*/5 * * * *"
    ["DISK_CLEANUP_TIME"]="0 4 * * 0"
    ["SYSTEM_REPORT_TIME"]="0 3 * * *"
)

# 系统资源限制
LIMITS_CONFIG=(
    ["NOFILE_SOFT"]="65535"
    ["NOFILE_HARD"]="65535"
    ["NPROC_SOFT"]="65535"
    ["NPROC_HARD"]="65535"
)

# 工具安装配置
TOOLS_CONFIG=(
    ["ESSENTIAL_TOOLS"]="git,curl,wget,vim,htop,tmux"
    ["NETWORK_TOOLS"]="iperf3,iftop,mtr,tcpdump,net-tools"
    ["SECURITY_TOOLS"]="fail2ban,iptables,ipset"
    ["MONITORING_TOOLS"]="htop,iftop,net-tools"
    ["VPN_TOOLS"]="wireguard-tools,qrencode"
    ["UTILITY_TOOLS"]="jq,bc,screen,tmux,rsync,unzip,zip"
)

# 日志配置
LOG_CONFIG=(
    ["LOG_LEVEL"]="INFO"
    ["LOG_FORMAT"]="%Y-%m-%d %H:%M:%S"
    ["LOG_RETENTION_DAYS"]="30"
    ["LOG_MAX_SIZE"]="100M"
) 