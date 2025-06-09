#!/bin/bash

log_optimize(){
  # 检查是否以 root 权限运行
  if [ "$EUID" -ne 0 ]; then
    echo "错误：请使用 sudo 运行此脚本"
    return 1
  fi

  echo "开始优化日志系统，减少 systemd-journald 和 rsyslogd 的内存占用..."

  # 创建配置备份
  echo "创建配置文件备份..."
  if [ -f /etc/systemd/journald.conf ]; then
    cp /etc/systemd/journald.conf /etc/systemd/journald.conf.bak
  fi

  # 1. 限制 systemd-journald 的日志大小
  echo "调整 systemd-journald 配置..."
  cat > /etc/systemd/journald.conf << 'EOF'
[Journal]
Storage=auto
RuntimeMaxUse=100M
SystemMaxUse=200M
MaxRetentionSec=1week
Compress=yes
EOF

  # 2. 重新加载配置并清理已有日志
  echo "重启 systemd-journald 并清理日志..."
  if ! systemctl restart systemd-journald; then
    echo "警告：systemd-journald 重启失败，尝试恢复备份..."
    cp /etc/systemd/journald.conf.bak /etc/systemd/journald.conf
    systemctl restart systemd-journald
    return 1
  fi

  # 清理日志
  journalctl --vacuum-size=200M || echo "警告：日志清理失败"

  # 3. 检查并配置 rsyslog
  if systemctl is-active --quiet rsyslog; then
    echo "配置 rsyslog..."
    # 创建 rsyslog 配置备份
    if [ -f /etc/rsyslog.conf ]; then
      cp /etc/rsyslog.conf /etc/rsyslog.conf.bak
    fi

    # 优化 rsyslog 配置
    cat > /etc/rsyslog.conf << 'EOF'
$ModLoad imuxsock
$ModLoad imjournal
$WorkDirectory /var/lib/rsyslog
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
$FileOwner root
$FileGroup adm
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022
$WorkDirectory /var/lib/rsyslog
$ActionQueueType LinkedList
$ActionQueueMaxDiskSpace 1g
$ActionQueueFileName queue
$ActionQueueMaxFileSize 10m
$ActionResumeRetryCount -1
*.emerg :omusrmsg:*
*.=alert|*.=crit|*.=err|*.=warning|auth,authpriv.none|mail.none -/var/log/syslog
*.=info|*.=notice|*.=warn|auth,authpriv.none|mail.none -/var/log/syslog
auth,authpriv.* -/var/log/auth.log
mail.* -/var/log/mail.log
kern.* -/var/log/kern.log
cron.* -/var/log/cron.log
*.=debug|auth,authpriv.none|mail.none -/var/log/debug
*.=info|*.=notice|*.=warn|auth,authpriv.none|mail.none -/var/log/messages
EOF

    # 重启 rsyslog
    if ! systemctl restart rsyslog; then
      echo "警告：rsyslog 重启失败，尝试恢复备份..."
      cp /etc/rsyslog.conf.bak /etc/rsyslog.conf
      systemctl restart rsyslog
      return 1
    fi
  fi

  # 4. 设置日志轮转
  echo "配置日志轮转..."
  cat > /etc/logrotate.d/rsyslog << 'EOF'
/var/log/syslog
/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
/var/log/messages
{
    rotate 7
    daily
    missingok
    notifempty
    delaycompress
    compress
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
EOF

  echo "日志系统优化完成！"
  echo "建议：请检查 /var/log 目录下的日志文件大小，确保优化生效。"
}
