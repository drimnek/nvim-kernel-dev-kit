-- SPDX-License-Identifier: GPL-3.0-or-later
require("core.options")
require("core.keymaps")
require("plugins")

require("kernel.context")
require("kernel.lsp")
require("kernel.build")
require("kernel.index")
require("kernel.search")
require("kernel.init_module")
require("kernel.commands")

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local c = require("kernel.context").resolve()

    if c.mode == "normal" then
      return
    end

    vim.g.kernel_nav_scope = c.nav_scope

    vim.notify(
      string.format(
        "kernel-dev: mode=%s target=%s scope=%s",
        c.mode,
        c.target_name or "none",
        c.nav_scope or "project"
      )
    )
  end,
})
