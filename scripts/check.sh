#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck install.sh uninstall.sh bin/knvim scripts/*.sh
else
  echo "shellcheck not found; skipping shell lint"
fi

if command -v luac5.4 >/dev/null 2>&1; then
  find config/nvim-kernel/lua -name '*.lua' -print0 | xargs -0 -n1 luac5.4 -p
elif command -v luac >/dev/null 2>&1; then
  find config/nvim-kernel/lua -name '*.lua' -print0 | xargs -0 -n1 luac -p
else
  echo "luac not found; skipping Lua syntax check"
fi
