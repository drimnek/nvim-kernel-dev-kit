-- SPDX-License-Identifier: GPL-3.0-or-later
local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open file explorer" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", {
  desc = "Diagnostics list",
})

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

local build = require("kernel.build")
local index = require("kernel.index")
local search = require("kernel.search")

map("n", "<leader>ki", "<cmd>KernelInfo<CR>", {
  desc = "Kernel context info",
})

map("n", "<leader>kb", build.build, {
  desc = "Kernel build",
})

map("n", "<leader>kB", build.clean, {
  desc = "Kernel clean",
})

map("n", "<leader>kI", index.gen_compile_commands, {
  desc = "Kernel generate compile_commands",
})

map("n", "<leader>kC", index.build_cscope, {
  desc = "Kernel build cscope",
})

map("n", "<leader>ks", search.toggle_scope, {
  desc = "Kernel toggle scope",
})

map("n", "<leader>kf", search.find_files, {
  desc = "Kernel find files by scope",
})

map("n", "<leader>kg", search.grep, {
  desc = "Kernel grep by scope",
})

map("n", "<leader>kw", search.grep_word, {
  desc = "Kernel grep word by scope",
})

map("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", {
  desc = "Markdown inline render toggle",
})
