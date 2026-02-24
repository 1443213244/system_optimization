# Debian 系统优化脚本

一个简单的 Debian 系统优化脚本，用于自动化系统配置和优化。

## 功能

- 系统更新
- 工具安装
- SSH 优化
- 网络优化
- 防火墙配置
- 定时任务管理
- WireGuard 安装
- 安全设置
- 内核参数优化

## 使用方法

1. 克隆仓库：
```bash
git clone https://github.com/1443213244/system_optimization.git
cd system_optimization
```

2. 运行脚本：
```bash
sudo bash main.sh
```

## 模块说明

- `main.sh`: 主脚本
- `modules/`: 功能模块目录
  - `tools_install.sh`: 安装必要工具
  - `system_update.sh`: 系统更新
  - `ssh_optimize.sh`: SSH 配置优化
  - `network_optimize.sh`: 网络参数优化
  - `firewall_optimize.sh`: 防火墙配置
  - `cron_optimize.sh`: 定时任务管理
  - `wireguard_install.sh`: WireGuard 安装
  - `security_optimize.sh`: 安全设置
  - `kernel_optimize.sh`: 内核参数优化

## 注意事项

- 仅支持 Debian 系统
- 需要 root 权限运行
- 建议在运行前备份重要数据

## 日志

- 日志文件位置：`/var/log/system_optimization.log`
- 备份文件位置：`/var/backups/system_optimization/` 