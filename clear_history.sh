#!/usr/bin/env bash
# clear_history.sh — 删除最近10小时内的 Bash、Zsh、Fish 历史，并在当前 Shell 中禁用后续命令记录
#
# ⚠️ 注意：必须通过 source 或 “. clear_history.sh” 方式在当前 Shell 中执行本脚本，
#     才能让 unset HISTFILE 和 set +o history 生效。

set -euo pipefail

# 1. 计算阈值：10 小时前的 Unix 时间戳
cutoff=$(date -d '10 hours ago' +%s)

# 2. Bash 历史
bash_hist="${HISTFILE:-$HOME/.bash_history}"
if [ -f "$bash_hist" ]; then
  awk -v cutoff="$cutoff" '
    $0 ~ /^#/ {
      ts = substr($0, 2)
      keep = (ts < cutoff)
      if (keep) { print; keep=1 } else { keep=0 }
      next
    }
    keep { print }
  ' "$bash_hist" > "${bash_hist}.tmp" && mv "${bash_hist}.tmp" "$bash_hist"
  # 清除当前 session 并写回文件
  history -c
  history -w
fi

# 3. Zsh 历史
zsh_hist="$HOME/.zsh_history"
if [ -f "$zsh_hist" ]; then
  awk -v cutoff="$cutoff" 'BEGIN{FS=";"} 
    $0 ~ /^: [0-9]+:/ {
      split($0, a, /[ :;]/)
      ts = a[2]
      if (ts < cutoff) print
    }
  ' "$zsh_hist" > "${zsh_hist}.tmp" && mv "${zsh_hist}.tmp" "$zsh_hist"
fi

# 4. Fish 历史
fish_hist="$HOME/.local/share/fish/fish_history"
if [ -f "$fish_hist" ]; then
  # 保留版本头
  head -n 1 "$fish_hist" > "${fish_hist}.tmp"
  awk -v cutoff="$cutoff" '
    /^- cmd: / {
      cmd = $0
      getline
      if ($0 ~ /when: /) {
        ts = $0; sub(/.*when: /, "", ts)
        if (ts < cutoff) {
          print cmd "\n" $0
        }
      }
    }
  ' "$fish_hist" >> "${fish_hist}.tmp"
  mv "${fish_hist}.tmp" "$fish_hist"
fi

echo "✅ 已删除最近10小时内的命令历史记录。"

# 5. 禁用后续命令历史记录（只在当前 Shell 生效）
unset HISTFILE
set +o history
