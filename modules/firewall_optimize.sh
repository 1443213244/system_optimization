#!/bin/bash

optimize_firewall() {
    log_info "开始优化防火墙配置..."
    
    ######################################################################
    # 1. 处理 iptables / ip6tables（老版本默认）                         #
    ######################################################################
    if command -v iptables >/dev/null 2>&1; then
        log_info "禁用 IPv4 iptables 规则..."
        iptables -P INPUT   ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT  ACCEPT
        iptables -F
        iptables -t nat    -F
        iptables -t mangle -F
        check_status "IPv4 iptables 规则已清除" "IPv4 iptables 规则清除失败"
    else
        log_warn "未检测到 iptables —— 跳过 IPv4 规则处理"
    fi

    if command -v ip6tables >/dev/null 2>&1; then
        log_info "禁用 IPv6 ip6tables 规则..."
        ip6tables -P INPUT   ACCEPT
        ip6tables -P FORWARD ACCEPT
        ip6tables -P OUTPUT  ACCEPT
        ip6tables -F
        ip6tables -t nat    -F 2>/dev/null || true
        ip6tables -t mangle -F
        check_status "IPv6 ip6tables 规则已清除" "IPv6 ip6tables 规则清除失败"
    else
        log_warn "未检测到 ip6tables —— 跳过 IPv6 规则处理"
    fi

    ######################################################################
    # 2. 处理 nftables（Debian 10+ 默认）                                #
    ######################################################################
    if command -v nft >/dev/null 2>&1; then
        log_info "禁用 nftables 规则并停止服务..."
        systemctl stop nftables  2>/dev/null || true
        systemctl disable nftables 2>/dev/null || true
        nft flush ruleset || true
        check_status "nftables 已禁用" "nftables 禁用失败"
    else
        log_warn "未检测到 nftables —— 跳过"
    fi

    ######################################################################
    # 3. 停止并禁用常见防火墙管理服务                                    #
    ######################################################################
    for svc in ufw firewalld netfilter-persistent; do
        if systemctl list-unit-files | grep -q "^${svc}\."; then
            log_info "停止并禁用服务 ${svc} ..."
            systemctl stop "${svc}"    2>/dev/null || true
            systemctl disable "${svc}" 2>/dev/null || true
            check_status "${svc} 服务已禁用" "${svc} 服务禁用失败"
        fi
    done

    log_info "防火墙已彻底禁用（规则文件仍保留，可随时恢复）"
    return 0
} 