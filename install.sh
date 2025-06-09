#!/bin/bash

# 设置安装目录
INSTALL_DIR="/opt/system_optimization"

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 创建安装目录
mkdir -p "$INSTALL_DIR"

# 复制所有文件到安装目录
cp -r ./* "$INSTALL_DIR/"

# 设置执行权限
chmod +x "$INSTALL_DIR/main.sh"
chmod +x "$INSTALL_DIR/modules/"*.sh

# 创建软链接
ln -sf "$INSTALL_DIR/main.sh" /usr/local/bin/system-optimize

echo "安装完成！"
echo "您可以通过以下方式运行系统优化："
echo "1. 直接运行: system-optimize"
echo "2. 或运行: $INSTALL_DIR/main.sh" 