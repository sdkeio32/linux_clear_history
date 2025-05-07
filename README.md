# linux_clear_history
一行命令清除linux历史命令行记录，支持linux全系系统
```bash
sh -c 'f=$(mktemp) && curl -fsSL https://raw.githubusercontent.com/sdkeio32/linux_clear_history/main/clear_history.sh -o "$f" && chmod +x "$f" && "$f" && rm -f "$f"'
