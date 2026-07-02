-- SPDX-License-Identifier: GPL-3.0-or-later
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.wrap = false

-- Kernel style defaults.
vim.o.expandtab = false
vim.o.tabstop = 8
vim.o.shiftwidth = 8
vim.o.softtabstop = 8

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.updatetime = 300
vim.o.timeoutlen = 500
vim.o.termguicolors = true

-- Project-local config support.
-- Prefer .kdev.json for data-only config. Use .nvim.lua only in trusted repositories.
vim.o.exrc = true
vim.o.secure = true
