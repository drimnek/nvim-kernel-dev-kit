-- SPDX-License-Identifier: GPL-3.0-or-later
local context = require("kernel.context")
local M = {}

local function write_if_missing(path, data)
  if vim.fn.filereadable(path) == 1 then
    vim.notify("Exists: " .. path)
    return
  end

  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")

  local fd = assert(io.open(path, "w"))
  fd:write(data)
  fd:close()

  vim.notify("Created: " .. path)
end

function M.init_module(name)
  local c = context.resolve()

  if not name or name == "" then
    name = vim.fn.fnamemodify(c.project_root, ":t")
  end

  local module_obj = name:gsub("-", "_")

  write_if_missing(c.project_root .. "/Kbuild", string.format([[
obj-m := %s.o

%s-y := src/%s.o

ccflags-y += -I$(src)/include
]], module_obj, module_obj, module_obj))

  write_if_missing(c.project_root .. "/Makefile", [[
KDIR ?= /lib/modules/$(shell uname -r)/build
ARCH ?=
CROSS_COMPILE ?=

default:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
]])

  write_if_missing(c.project_root .. "/src/" .. module_obj .. ".c", string.format([[
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

static int __init %s_init(void)
{
	pr_info("%s: init\n");
	return 0;
}

static void __exit %s_exit(void)
{
	pr_info("%s: exit\n");
}

module_init(%s_init);
module_exit(%s_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("%s external kernel module");
MODULE_AUTHOR("unknown");
]], module_obj, module_obj, module_obj, module_obj, module_obj, module_obj, name))

  write_if_missing(c.project_root .. "/include/" .. module_obj .. ".h", [[
#pragma once
]])

  write_if_missing(c.project_root .. "/.clangd", [[
CompileFlags:
  CompilationDatabase: .
  Remove:
    - -fconserve-stack
    - -fno-allow-store-data-races
    - -mpreferred-stack-boundary=*
    - -mno-*
    - -mindirect-branch*
    - -mindirect-branch-register
    - -fmin-function-alignment=*
  Add:
    - -Wno-unknown-warning-option
    - -Wno-ignored-optimization-argument

Completion:
  HeaderInsertion: Never

Index:
  Background: Build
]])

  vim.notify("External kernel module skeleton initialized")
end

return M
