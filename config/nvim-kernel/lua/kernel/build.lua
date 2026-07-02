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

local function cross_arg(c)
  if c.cross_compile and c.cross_compile ~= "" then
    return "CROSS_COMPILE=" .. q(c.cross_compile)
  end
  return ""
end

local function validate_kernel_paths(c)
  if not c.kernel_root or c.kernel_root == "" then
    vim.notify("kernel_root is not configured", vim.log.levels.ERROR)
    return false
  end

  if not c.kernel_build or c.kernel_build == "" then
    vim.notify("kernel_build is not configured", vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.build()
  local c = context.resolve()

  if c.mode == "in_tree" then
    if not validate_kernel_paths(c) then
      return
    end

    term(table.concat({
      "make",
      "-C", q(c.kernel_root),
      "O=" .. q(c.kernel_build),
      "ARCH=" .. q(c.arch),
      cross_arg(c),
      "-j$(nproc)",
    }, " "))

    return
  end

  if c.mode == "out_of_tree" then
    if not validate_kernel_paths(c) then
      return
    end

    term(table.concat({
      "make",
      "-C", q(c.kernel_root),
      "O=" .. q(c.kernel_build),
      "M=" .. q(c.driver_root),
      "ARCH=" .. q(c.arch),
      cross_arg(c),
      "modules",
    }, " "))

    return
  end

  if c.mode == "external_dir" then
    vim.notify(
      "This folder is attached to kernel-dev, but it is not an external module yet. Use :KernelInitModule <name>.",
      vim.log.levels.WARN
    )
    return
  end

  vim.notify("Not in kernel-dev context", vim.log.levels.ERROR)
end

function M.clean()
  local c = context.resolve()

  if c.mode == "in_tree" then
    if not validate_kernel_paths(c) then
      return
    end

    term(table.concat({
      "make",
      "-C", q(c.kernel_root),
      "O=" .. q(c.kernel_build),
      "clean",
    }, " "))

    return
  end

  if c.mode == "out_of_tree" then
    if not validate_kernel_paths(c) then
      return
    end

    term(table.concat({
      "make",
      "-C", q(c.kernel_root),
      "O=" .. q(c.kernel_build),
      "M=" .. q(c.driver_root),
      "clean",
    }, " "))

    return
  end

  vim.notify("Nothing to clean for mode: " .. c.mode, vim.log.levels.WARN)
end

return M
