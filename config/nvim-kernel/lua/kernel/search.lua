-- SPDX-License-Identifier: GPL-3.0-or-later
local context = require("kernel.context")
local M = {}

local scopes = { "project", "compiled", "kernel", "all" }

local function q(s)
  return vim.fn.shellescape(s or "")
end

local function file_exists(path)
  return path and vim.fn.filereadable(path) == 1
end

local function telescope()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("telescope.nvim is not available", vim.log.levels.ERROR)
    return nil
  end
  return builtin
end

function M.current_scope()
  local c = context.resolve()
  return vim.g.kernel_nav_scope or c.nav_scope or "project"
end

function M.set_scope(scope)
  vim.g.kernel_nav_scope = scope
  vim.notify("Kernel scope: " .. scope)
end

function M.toggle_scope()
  local cur = M.current_scope()

  local idx = 1
  for i, s in ipairs(scopes) do
    if s == cur then
      idx = i
      break
    end
  end

  local next_idx = idx + 1
  if next_idx > #scopes then
    next_idx = 1
  end

  M.set_scope(scopes[next_idx])
end

function M.find_files()
  local c = context.resolve()
  local scope = M.current_scope()
  local builtin = telescope()

  if not builtin then
    return
  end

  if scope == "project" then
    builtin.find_files({
      prompt_title = "Project files",
      cwd = c.project_root,
      hidden = true,
    })
    return
  end

  if scope == "kernel" then
    if not c.kernel_root or c.kernel_root == "" then
      vim.notify("kernel_root is not configured", vim.log.levels.ERROR)
      return
    end

    builtin.find_files({
      prompt_title = "Kernel files",
      cwd = c.kernel_root,
      hidden = true,
    })
    return
  end

  if scope == "all" then
    local dirs = { c.project_root }

    if c.kernel_root and c.kernel_root ~= "" and c.kernel_root ~= c.project_root then
      table.insert(dirs, c.kernel_root)
    end

    builtin.find_files({
      prompt_title = "Project + kernel files",
      search_dirs = dirs,
      hidden = true,
    })
    return
  end

  if scope == "compiled" then
    if not file_exists(c.used_files) then
      vim.notify("Missing used-files: " .. c.used_files, vim.log.levels.ERROR)
      return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
      prompt_title = "Compiled files",
      finder = finders.new_oneshot_job({
        "bash",
        "-lc",
        "cat " .. q(c.used_files),
      }),
      sorter = conf.generic_sorter({}),
      previewer = conf.file_previewer({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          if entry and entry[1] then
            vim.cmd.edit(vim.fn.fnameescape(entry[1]))
          end
        end)
        return true
      end,
    }):find()
  end
end

function M.grep()
  local c = context.resolve()
  local scope = M.current_scope()
  local builtin = telescope()

  if not builtin then
    return
  end

  if scope == "project" then
    builtin.live_grep({
      prompt_title = "Project grep",
      cwd = c.project_root,
    })
    return
  end

  if scope == "kernel" then
    if not c.kernel_root or c.kernel_root == "" then
      vim.notify("kernel_root is not configured", vim.log.levels.ERROR)
      return
    end

    builtin.live_grep({
      prompt_title = "Kernel grep",
      cwd = c.kernel_root,
    })
    return
  end

  if scope == "all" then
    local dirs = { c.project_root }

    if c.kernel_root and c.kernel_root ~= "" and c.kernel_root ~= c.project_root then
      table.insert(dirs, c.kernel_root)
    end

    builtin.live_grep({
      prompt_title = "Project + kernel grep",
      search_dirs = dirs,
    })
    return
  end

  if scope == "compiled" then
    local pattern = vim.fn.input("Compiled grep > ")
    if pattern == nil or pattern == "" then
      return
    end

    if not file_exists(c.used_files) then
      vim.notify("Missing used-files: " .. c.used_files, vim.log.levels.ERROR)
      return
    end

    local cmd = table.concat({
      "xargs -a",
      q(c.used_files),
      "rg --vimgrep --no-heading --color=never --",
      q(pattern),
    }, " ")

    local lines = vim.fn.systemlist(cmd)

    vim.fn.setqflist({}, "r", {
      title = "Compiled grep: " .. pattern,
      lines = lines,
    })

    vim.cmd("copen")
  end
end

function M.grep_word()
  local word = vim.fn.expand("<cword>")
  if not word or word == "" then
    return
  end

  local c = context.resolve()
  local scope = M.current_scope()
  local builtin = telescope()

  if not builtin then
    return
  end

  if scope == "compiled" then
    if not file_exists(c.used_files) then
      vim.notify("Missing used-files: " .. c.used_files, vim.log.levels.ERROR)
      return
    end

    local cmd = table.concat({
      "xargs -a",
      q(c.used_files),
      "rg --vimgrep --no-heading --color=never --",
      q(word),
    }, " ")

    local lines = vim.fn.systemlist(cmd)

    vim.fn.setqflist({}, "r", {
      title = "Compiled grep word: " .. word,
      lines = lines,
    })

    vim.cmd("copen")
    return
  end

  if scope == "project" then
    builtin.grep_string({
      prompt_title = "Project grep word",
      cwd = c.project_root,
      search = word,
    })
    return
  end

  if scope == "kernel" then
    builtin.grep_string({
      prompt_title = "Kernel grep word",
      cwd = c.kernel_root,
      search = word,
    })
    return
  end

  local dirs = { c.project_root }

  if c.kernel_root and c.kernel_root ~= "" and c.kernel_root ~= c.project_root then
    table.insert(dirs, c.kernel_root)
  end

  builtin.grep_string({
    prompt_title = "Project + kernel grep word",
    search_dirs = dirs,
    search = word,
  })
end

return M
