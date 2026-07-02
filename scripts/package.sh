#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

name="${1:-nvim-kernel-dev-kit}"
out="${2:-dist}"

mkdir -p "$out"
zip -r "$out/$name.zip" . \
  -x '.git/*' \
  -x "$out/*" \
  -x '*.zip'
