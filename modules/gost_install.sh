#!/bin/bash
source modules/log.sh

install_gost3(){
    # 如果没有预设的 IS_CHINA 环境变量，进行自动检测
    if [ -z "$IS_CHINA" ]; then
        IS_CHINA=false
        if curl -s --max-time 3 https://myip.ipip.net | grep -q "中国" || ! curl -s --max-time 3 -I https://www.google.com >/dev/null 2>&1; then
            IS_CHINA=true
        fi
    fi

    local clone_url=""
    if [ "$IS_CHINA" = "true" ]; then
        log_info "检测当前为国内环境，将从 Gitee 克隆 EasyGost3..."
        if [ -n "$GITEE_TOKEN" ] && [ "$GITEE_TOKEN" != "你的_gitee_个人访问令牌" ]; then
            clone_url="https://oauth2:${GITEE_TOKEN}@gitee.com/1443213244/EasyGost3.git"
        else
            clone_url="https://gitee.com/1443213244/EasyGost3.git"
        fi
    else
        log_info "检测当前为海外环境，将从 GitHub 克隆 EasyGost3..."
        clone_url="https://oauth2:${GITHUB_TOKEN}@github.com/1443213244/EasyGost3.git"
    fi

    log_info "开始克隆 EasyGost3 仓库..."
    git clone "$clone_url" EasyGost3
    check_status "gost" "EasyGost3 仓库下载失败" || return 1
    
    cd EasyGost3 || {
        log_error "无法进入 EasyGost3 目录"
        return 1
    }
    
    bash install.sh
    check_status "gost" "gost & gost3 安装失败" || {
        cd ..
        return 1
    }
    
    cd ..
    rm -rf EasyGost3
    return 0
}