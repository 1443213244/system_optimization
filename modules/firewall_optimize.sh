#!/bin/bash
source modules/log.sh

optimize_firewall() {
        set -e
        log() { printf "\033[1;33m🛑 %s\033[0m\n" "$*"; }

        ######################################################################
        # 1. 处理 iptables / ip6tables（老版本默认）                         #
        ######################################################################
        if command -v iptables >/dev/null 2>&1; then
        log "禁用 IPv4 iptables 规则..."
        iptables -P INPUT   ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT  ACCEPT
        iptables -F
        iptables -t nat    -F
        iptables -t mangle -F
        else
        log "未检测到 iptables —— 跳过 IPv4 规则处理"
        fi

        if command -v ip6tables >/dev/null 2>&1; then
        log "禁用 IPv6 ip6tables 规则..."
        ip6tables -P INPUT   ACCEPT
        ip6tables -P FORWARD ACCEPT
        ip6tables -P OUTPUT  ACCEPT
        ip6tables -F
        ip6tables -t nat    -F 2>/dev/null || true
        ip6tables -t mangle -F
        else
        log "未检测到 ip6tables —— 跳过 IPv6 规则处理"
        fi

        ######################################################################
        # 2. 处理 nftables（Debian 10+ 默认）                                #
        ######################################################################
        if command -v nft >/dev/null 2>&1; then
        log "禁用 nftables 规则并停止服务..."
        systemctl stop nftables  2>/dev/null || true
        systemctl disable nftables 2>/dev/null || true
        nft flush ruleset || true
        else
        log "未检测到 nftables —— 跳过"
        fi

        ######################################################################
        # 3. 停止并禁用常见防火墙管理服务                                    #
        ######################################################################
        for svc in ufw firewalld netfilter-persistent; do
        if systemctl list-unit-files | grep -q "^${svc}\."; then
            log "停止并禁用服务 ${svc} ..."
            systemctl stop "${svc}"    2>/dev/null || true
            systemctl disable "${svc}" 2>/dev/null || true
        fi
        done

        log "防火墙已彻底禁用（规则文件仍保留，可随时恢复）"
    return 0
} 
