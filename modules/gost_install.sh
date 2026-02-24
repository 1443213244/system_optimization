#!/bin/bash
source modules/log.sh

install_gost(){
    log_info "下载 wgrest 二进制文件..."
    git clone https://${GITHUB_TOKEN}@github.com/1443213244/EasyGost3.git
    check_status "gost" "wgrest 二进制文件下载失败" || return 1
    
    cd EasyGost3 || {
        log_error "无法进入 EasyGost3 目录"
        return 1
    }
    
    bash install.sh
    check_status "gost" "wgrest 安装失败" || {
        cd ..
        return 1
    }
    
    cd ..
    rm -rf EasyGost3
    return 0
}