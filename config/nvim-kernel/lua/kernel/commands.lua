-- SPDX-License-Identifier: GPL-3.0-or-later
local context = require("kernel.context")
local build = require("kernel.build")
local index = require("kernel.index")
local search = require("kernel.search")
local init_module = require("kernel.init_module")

vim.api.nvim_create_user_command("KernelInfo", function()
  context.print()
end, {})

vim.api.nvim_create_user_command("KernelBuild", function()
  build.build()
end, {})

vim.api.nvim_create_user_command("KernelClean", function()
  build.clean()
end, {})

vim.api.nvim_create_user_command("KernelIndex", function()
  index.gen_compile_commands()
end, {})

vim.api.nvim_create_user_command("KernelCscope", function()
  index.build_cscope()
end, {})

vim.api.nvim_create_user_command("KernelScope", function(opts)
  if opts.args == "" then
    search.toggle_scope()
  else
    search.set_scope(opts.args)
  end
end, {
  nargs = "?",
  complete = function()
    return { "project", "compiled", "kernel", "all" }
  end,
})

vim.api.nvim_create_user_command("KernelInitModule", function(opts)
  init_module.init_module(opts.args)
end, {
  nargs = "?",
})
