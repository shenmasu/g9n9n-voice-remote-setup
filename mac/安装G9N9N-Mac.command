#!/bin/zsh
# Finder double-click entry point. Installs to /Applications, then shows a
# read-only runtime check. It never replaces an existing verified 0.2.0 app.
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

chmod +x "$ROOT/install.sh" "$ROOT/build.sh" \
  "$ROOT/scripts/run-tests.sh" "$ROOT/scripts/check-mac-runtime.sh"
"$ROOT/install.sh"

printf '\n只读运行环境自检：\n'
sh "$ROOT/scripts/check-mac-runtime.sh" || true
printf '如需完成蓝牙、权限和微信输入法设置，请按安装输出由机主本人操作。\n'
printf '按回车关闭此窗口。'
read -r _ || true
