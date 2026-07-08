#!/bin/bash
source modules/log.sh

check_is_china() {
    local is_china=false
    # 尝试通过 ipip.net 接口判断
    if curl -s --max-time 3 https://myip.ipip.net | grep -q "中国"; then
        is_china=true
    # 如果无法连接到 Google，也默认为国内环境
    elif ! curl -s --max-time 3 -I https://www.google.com >/dev/null 2>&1; then
        is_china=true
    fi
    echo "$is_china"
}

install_gost3(){
    local is_china=$(check_is_china)
    local clone_url=""

    if [ "$is_china" = "true" ]; then
        log_info "检测当前为国内环境，将从 Gitee 克隆 EasyGost3..."
        if [ -n "$GITEE_TOKEN" ]; then
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