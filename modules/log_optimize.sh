#!/bin/bash
source modules/log.sh

log_optimize(){
  # log-minimize.sh  ── 将 systemd‑journald 占用压缩到极限 (~8 MiB)

  set -euo pipefail

  log_info "▸ 准备最小化 systemd‑journald …"

  # 1) 写入 drop‑in 配置（不覆盖原文件，升级安全）
  sudo mkdir -p /etc/systemd/journald.conf.d
  sudo tee /etc/systemd/journald.conf.d/10-minimize.conf >/dev/null <<'EOF'
[Journal]
Storage=volatile          # 仅驻留 /run (tmpfs)
RuntimeMaxUse=8M          # 总空间上限
RuntimeMaxFileSize=4M     # 单文件上限（systemd 247 的硬下限）
MaxFileSec=600s           # 每 600 s 轮转一次，旧文件立即归档
Compress=no               # 关闭压缩，省 CPU
EOF

  # 2) 重启 journald & 清理旧持久日志
  sudo systemctl restart systemd-journald
  sudo journalctl --rotate
  sudo journalctl --vacuum-time=1s

  # 3) 可选：停用 rsyslog（若系统还有它）
  if systemctl list-unit-files | grep -q '^rsyslog\.service'; then
    if systemctl is-active --quiet rsyslog;   then sudo systemctl stop rsyslog;   fi
    if systemctl is-enabled --quiet rsyslog;  then sudo systemctl disable rsyslog; fi
    # 如确定永不用，可执行下一行彻底屏蔽
    # sudo systemctl mask rsyslog
  fi

  echo "▸ 完成。当前日志占用：$(journalctl --disk-usage)"
}
