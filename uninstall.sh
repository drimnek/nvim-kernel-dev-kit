#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

APPNAME="${APPNAME:-nvim-kernel}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
WRAPPER_NAME="${WRAPPER_NAME:-knvim}"

REMOVE_CONFIG=0
REMOVE_DATA=0
FORCE=0

usage() {
  cat <<EOF
Usage: ./uninstall.sh [options]

Options:
  --remove-config  Remove ~/.config/<APPNAME>.
  --remove-data    Remove data/state/cache for the profile.
  --force          Do not prompt before destructive actions.
  -h, --help       Show this help.

Environment:
  APPNAME          Neovim app profile name. Default: nvim-kernel
  BIN_DIR          Wrapper directory. Default: ~/.local/bin
  WRAPPER_NAME     Wrapper name. Default: knvim
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remove-config) REMOVE_CONFIG=1 ;;
    --remove-data) REMOVE_DATA=1 ;;
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

confirm() {
  local msg="$1"
  if [[ "$FORCE" == "1" ]]; then
    return 0
  fi
  read -r -p "$msg [y/N] " ans
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

wrapper="$BIN_DIR/$WRAPPER_NAME"
if [[ -e "$wrapper" ]]; then
  rm -f "$wrapper"
  echo "Removed wrapper: $wrapper"
fi

if [[ "$REMOVE_CONFIG" == "1" ]]; then
  cfg="$XDG_CONFIG_HOME/$APPNAME"
  if [[ -d "$cfg" ]] && confirm "Remove config directory $cfg?"; then
    rm -rf "$cfg"
    echo "Removed config: $cfg"
  fi
fi

if [[ "$REMOVE_DATA" == "1" ]]; then
  for path in "$XDG_DATA_HOME/$APPNAME" "$XDG_STATE_HOME/$APPNAME" "$XDG_CACHE_HOME/$APPNAME"; do
    if [[ -e "$path" ]] && confirm "Remove $path?"; then
      rm -rf "$path"
      echo "Removed: $path"
    fi
  done
fi

echo "Uninstall complete."
