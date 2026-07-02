#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

APPNAME="${APPNAME:-nvim-kernel}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
INSTALL_CONFIG_DIR="$XDG_CONFIG_HOME/$APPNAME"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
WRAPPER_NAME="${WRAPPER_NAME:-knvim}"

INSTALL_DEPS=0
RESET_DATA=0
FORCE=0

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Options:
  --install-deps    Install recommended Ubuntu/Debian packages with apt.
  --reset-data      Remove Neovim data/state/cache for this profile before install.
  --force           Do not prompt before backing up existing config.
  -h, --help        Show this help.

Environment:
  APPNAME           Neovim app profile name. Default: nvim-kernel
  BIN_DIR           Wrapper install directory. Default: ~/.local/bin
  WRAPPER_NAME      Wrapper name. Default: knvim
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-deps) INSTALL_DEPS=1 ;;
    --reset-data) RESET_DATA=1 ;;
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

if [[ "$INSTALL_DEPS" == "1" ]]; then
  if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y \
      neovim git curl ripgrep fd-find jq \
      clang clangd llvm lld \
      build-essential bc bison flex libssl-dev libelf-dev \
      universal-ctags cscope global \
      gdb-multiarch trace-cmd
  else
    echo "apt not found. Install dependencies manually; see README.md." >&2
  fi
fi

mkdir -p "$BIN_DIR"

if [[ -d "$INSTALL_CONFIG_DIR" ]]; then
  backup="${INSTALL_CONFIG_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
  echo "Existing config found: $INSTALL_CONFIG_DIR"
  echo "Backup target: $backup"
  if [[ "$FORCE" != "1" ]]; then
    read -r -p "Backup existing config and continue? [y/N] " ans
    case "$ans" in
      y|Y|yes|YES) ;;
      *) echo "Aborted."; exit 1 ;;
    esac
  fi
  mv "$INSTALL_CONFIG_DIR" "$backup"
fi

mkdir -p "$INSTALL_CONFIG_DIR"
cp -a "$REPO_ROOT/config/nvim-kernel/." "$INSTALL_CONFIG_DIR/"

if [[ ! -f "$INSTALL_CONFIG_DIR/kernel-targets.json" ]]; then
  cp "$REPO_ROOT/config/nvim-kernel/kernel-targets.example.json" "$INSTALL_CONFIG_DIR/kernel-targets.json"
fi

install -m 0755 "$REPO_ROOT/bin/knvim" "$BIN_DIR/$WRAPPER_NAME"

# Optional fd compatibility on Debian/Ubuntu.
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$BIN_DIR/fd"
fi

if [[ "$RESET_DATA" == "1" ]]; then
  rm -rf "$XDG_DATA_HOME/$APPNAME" "$XDG_STATE_HOME/$APPNAME" "$XDG_CACHE_HOME/$APPNAME"
fi

cat <<EOF

Installed profile:
  $INSTALL_CONFIG_DIR

Installed wrapper:
  $BIN_DIR/$WRAPPER_NAME

Next steps:
  1. Edit: $INSTALL_CONFIG_DIR/kernel-targets.json
  2. Ensure $BIN_DIR is in PATH.
  3. Run: $WRAPPER_NAME .
  4. Inside Neovim, run: :KernelInfo

EOF
