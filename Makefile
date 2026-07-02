# SPDX-License-Identifier: GPL-3.0-or-later

SHELL := /bin/bash
APPNAME ?= nvim-kernel
WRAPPER_NAME ?= knvim
DIST_DIR ?= dist
PACKAGE_NAME ?= nvim-kernel-dev-kit

.PHONY: help install install-deps uninstall check lint lint-shell lint-lua format package clean

help:
	@echo "Targets:"
	@echo "  install       Install the nvim-kernel profile"
	@echo "  install-deps  Install recommended Ubuntu/Debian dependencies and profile"
	@echo "  uninstall     Remove wrapper and optionally config/data via uninstall.sh"
	@echo "  check         Run repository checks"
	@echo "  lint          Run shell and Lua checks"
	@echo "  format        Format Lua files with stylua when available"
	@echo "  package       Create a zip archive under dist/"
	@echo "  clean         Remove dist/"

install:
	APPNAME=$(APPNAME) WRAPPER_NAME=$(WRAPPER_NAME) ./install.sh --force

install-deps:
	APPNAME=$(APPNAME) WRAPPER_NAME=$(WRAPPER_NAME) ./install.sh --install-deps --force

uninstall:
	APPNAME=$(APPNAME) WRAPPER_NAME=$(WRAPPER_NAME) ./uninstall.sh

check: lint

lint: lint-shell lint-lua

lint-shell:
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck install.sh uninstall.sh bin/knvim scripts/*.sh; \
	else \
		echo "shellcheck not found; skipping shell lint"; \
	fi

lint-lua:
	@if command -v luac5.4 >/dev/null 2>&1; then \
		find config/nvim-kernel/lua -name '*.lua' -print0 | xargs -0 -n1 luac5.4 -p; \
	elif command -v luac >/dev/null 2>&1; then \
		find config/nvim-kernel/lua -name '*.lua' -print0 | xargs -0 -n1 luac -p; \
	else \
		echo "luac not found; skipping Lua syntax check"; \
	fi

format:
	@if command -v stylua >/dev/null 2>&1; then \
		stylua config/nvim-kernel/lua; \
	else \
		echo "stylua not found; skipping format"; \
	fi

package:
	mkdir -p $(DIST_DIR)
	zip -r $(DIST_DIR)/$(PACKAGE_NAME).zip . \
		-x '.git/*' \
		-x '$(DIST_DIR)/*' \
		-x '*.zip'

clean:
	rm -rf $(DIST_DIR)
