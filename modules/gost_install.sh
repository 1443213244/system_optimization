#!/bin/bash
source modules/log.sh

install_gost3(){
    log_info "下载 EasyGost3 仓库..."
    git clone https://${GITHUB_TOKEN}@github.com/1443213244/EasyGost3.git
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