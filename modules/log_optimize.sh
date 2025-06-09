#!/bin/bash

log_optimize(){
  echo "优化日志系统，减少 systemd-journald 和 rsyslogd 的内存占用..."

  # 1. 限制 systemd-journald 的日志大小
  echo "调整 systemd-journald 配置..."
  sudo tee /etc/systemd/journald.conf > /dev/null <<EOF
  [Journal]
  Storage=none
  RuntimeMaxUse=0
  SystemMaxUse=50M
  EOF
  
  # 2. 重新加载配置并清理已有日志
  echo "重启 systemd-journald 并清理日志..."
  sudo systemctl restart systemd-journald
  sudo journalctl --vacuum-size=50M
  
  # 3. 禁用 rsyslog（如果不需要）
  if systemctl is-active --quiet rsyslog; then
      echo "禁用 rsyslog..."
      sudo systemctl stop rsyslog
      sudo systemctl disable rsyslog
  fi
  
  # 4. 确保 rsyslog 彻底禁用（可选）
  if systemctl is-enabled --quiet rsyslog; then
      echo "屏蔽 rsyslog 以防止自动启动..."
      sudo systemctl mask rsyslog
  fi
  
  echo "日志优化完成！"

}
