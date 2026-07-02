-- SPDX-License-Identifier: GPL-3.0-or-later
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.c", "*.h" },
  callback = function()
    vim.bo.filetype = "c"
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

local clangd_cmd = {
  "clangd",
  "--background-index",
  "--completion-style=detailed",
  "--header-insertion=never",
  "--pch-storage=memory",
  "--query-driver=/usr/bin/*gcc,/usr/bin/*g++,/usr/bin/*clang,/opt/toolchains/**/bin/*",
}

if vim.lsp and vim.lsp.config then
  vim.lsp.config("clangd", {
    cmd = clangd_cmd,
    capabilities = capabilities,
    root_markers = {
      ".clangd",
      "compile_commands.json",
      ".kdev.json",
      "Kbuild",
      "Kconfig",
      ".git",
    },
    filetypes = { "c", "cpp" },
  })

  vim.lsp.enable("clangd")
else
  local ok, lspconfig = pcall(require, "lspconfig")
  if ok then
    local util = require("lspconfig.util")

    lspconfig.clangd.setup({
      cmd = clangd_cmd,
      capabilities = capabilities,
      root_dir = util.root_pattern(
        ".clangd",
        "compile_commands.json",
        ".kdev.json",
        "Kbuild",
        "Kconfig",
        ".git"
      ),
      filetypes = { "c", "cpp" },
    })
  end
end
