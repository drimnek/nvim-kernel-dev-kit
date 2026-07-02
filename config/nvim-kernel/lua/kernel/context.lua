-- SPDX-License-Identifier: GPL-3.0-or-later
local M = {}

local function cwd()
  return vim.fn.getcwd()
end

local function expand(path)
  if not path or path == "" then
    return path
  end
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p"):gsub("/$", "")
end

local function join(...)
  local parts = { ... }
  local out = {}
  for _, p in ipairs(parts) do
    if p and p ~= "" then
      table.insert(out, tostring(p):gsub("/+$", ""))
    end
  end
  return table.concat(out, "/")
end

local function file_exists(path)
  return path and vim.fn.filereadable(expand(path)) == 1
end

local function dir_exists(path)
  return path and vim.fn.isdirectory(expand(path)) == 1
end

local function read_file(path)
  path = expand(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end

  local data = fd:read("*a")
  fd:close()
  return data
end

local function load_json(path)
  local data = read_file(path)
  if not data then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, data)
  if not ok then
    vim.notify("Invalid JSON: " .. path, vim.log.levels.ERROR)
    return nil
  end

  return decoded
end

local function find_upward(markers, start)
  local dir = expand(start or cwd())

  while dir and dir ~= "/" do
    for _, marker in ipairs(markers) do
      local p = join(dir, marker)
      if file_exists(p) or dir_exists(p) then
        return dir
      end
    end

    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end

    dir = parent
  end

  return nil
end

local function looks_like_kernel_tree(root)
  if not root then
    return false
  end

  return file_exists(join(root, "MAINTAINERS"))
      and file_exists(join(root, "Kbuild"))
      and dir_exists(join(root, "include/linux"))
      and dir_exists(join(root, "drivers"))
end

local function looks_like_external_module(root)
  if not root then
    return false
  end

  local kbuild = read_file(join(root, "Kbuild")) or ""
  local makefile = read_file(join(root, "Makefile")) or ""

  return kbuild:match("obj%-m")
      or makefile:match("obj%-m")
      or makefile:match("M=%$%(")
      or makefile:match("M=%$PWD")
      or makefile:match("M=%$%(PWD%)")
end

local function registry_path()
  return vim.fn.stdpath("config") .. "/kernel-targets.json"
end

local function local_kdev_config(project_root)
  return load_json(join(project_root, ".kdev.json")) or {}
end

local function load_target(project_root)
  local registry = load_json(registry_path()) or {}
  local local_cfg = local_kdev_config(project_root)

  local target_name =
      vim.env.KDEV_TARGET
      or local_cfg.target
      or registry.default

  if not target_name then
    return nil, nil
  end

  local targets = registry.targets or {}
  return target_name, targets[target_name]
end

function M.resolve()
  local project_root = expand(cwd())
  local local_cfg = local_kdev_config(project_root)
  local cfg = vim.g.kernel_dev or {}

  local forced =
      vim.env.KDEV_FORCE == "1"
      or cfg.force == true
      or local_cfg.force == true

  local kernel_candidate = find_upward({
    "MAINTAINERS",
    "Kbuild",
    "Kconfig",
    "include/linux",
  }, project_root)

  local is_kernel = looks_like_kernel_tree(kernel_candidate)
  local is_oot = looks_like_external_module(project_root)

  local target_name, target = load_target(project_root)
  target = target or {}

  local mode =
      cfg.mode
      or local_cfg.mode

  if not mode then
    if is_kernel then
      mode = "in_tree"
    elseif is_oot then
      mode = "out_of_tree"
    elseif forced then
      mode = "external_dir"
    else
      mode = "normal"
    end
  end

  local kernel_root
  local kernel_build

  if mode == "in_tree" then
    kernel_root = expand(
      cfg.kernel_root
      or local_cfg.kernel_root
      or kernel_candidate
      or project_root
    )

    kernel_build = expand(
      cfg.kernel_build
      or local_cfg.kernel_build
      or vim.env.KERNEL_BUILD
      or vim.env.KBUILD_OUTPUT
      or join(kernel_root, "out/default")
    )
  else
    kernel_root = expand(
      cfg.kernel_root
      or local_cfg.kernel_root
      or vim.env.KERNEL_ROOT
      or target.kernel_root
      or ""
    )

    kernel_build = expand(
      cfg.kernel_build
      or local_cfg.kernel_build
      or vim.env.KERNEL_BUILD
      or vim.env.KBUILD_OUTPUT
      or target.kernel_build
      or ""
    )
  end

  local driver_root = expand(
      cfg.driver_root
      or local_cfg.driver_root
      or project_root
  )

  return {
    mode = mode,

    target_name = target_name or "none",

    project_root = project_root,
    driver_root = driver_root,

    kernel_root = kernel_root,
    kernel_build = kernel_build,

    arch =
        cfg.arch
        or local_cfg.arch
        or vim.env.ARCH
        or target.arch
        or "arm64",

    cross_compile =
        cfg.cross_compile
        or local_cfg.cross_compile
        or vim.env.CROSS_COMPILE
        or target.cross_compile
        or "",

    compile_commands = expand(
        cfg.compile_commands
        or local_cfg.compile_commands
        or join(project_root, "compile_commands.json")
    ),

    used_files = expand(
        cfg.used_files
        or local_cfg.used_files
        or join(project_root, ".nvim/used-files")
    ),

    nav_scope =
        vim.g.kernel_nav_scope
        or cfg.nav_scope
        or local_cfg.nav_scope
        or (mode == "external_dir" and "all" or "project"),
  }
end

function M.is_kernel_dev()
  local c = M.resolve()
  return c.mode == "in_tree"
      or c.mode == "out_of_tree"
      or c.mode == "external_dir"
end

function M.print()
  print(vim.inspect(M.resolve()))
end

return M
