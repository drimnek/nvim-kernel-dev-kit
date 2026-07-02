-- SPDX-License-Identifier: GPL-3.0-or-later
local context = require("kernel.context")
local M = {}

local function q(s)
  return vim.fn.shellescape(s or "")
end

local function term(cmd)
  vim.cmd("botright split")
  vim.cmd("resize 15")
  vim.cmd("terminal " .. cmd)
end

local function ensure_kernel_root(c)
  if not c.kernel_root or c.kernel_root == "" then
    vim.notify("kernel_root is not configured", vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.gen_compile_commands()
  local c = context.resolve()

  if not ensure_kernel_root(c) then
    return
  end

  local script = c.kernel_root .. "/scripts/clang-tools/gen_compile_commands.py"

  local db_dir

  if c.mode == "in_tree" then
    db_dir = c.kernel_build
  elseif c.mode == "out_of_tree" then
    db_dir = c.driver_root
  else
    vim.notify("compile_commands is available only for in_tree or out_of_tree modes", vim.log.levels.WARN)
    return
  end

  local used_dir = vim.fn.fnamemodify(c.used_files, ":h")

  local cmd = table.concat({
    "python3", q(script),
    "-d", q(db_dir),
    "-o", q(c.compile_commands),
    "&&",
    "mkdir -p", q(used_dir),
    "&&",
    "jq -r '.[].file'", q(c.compile_commands),
    "| sort -u >",
    q(c.used_files),
  }, " ")

  term(cmd)
end

function M.build_cscope()
  local c = context.resolve()

  local used = c.used_files
  local out = c.project_root .. "/.nvim/cscope.compiled.out"

  if vim.fn.filereadable(used) ~= 1 then
    vim.notify("Missing used-files: " .. used, vim.log.levels.ERROR)
    return
  end

  local cmd = table.concat({
    "mkdir -p", q(c.project_root .. "/.nvim"),
    "&&",
    "cscope -bq",
    "-i", q(used),
    "-f", q(out),
  }, " ")

  term(cmd)
end

return M
