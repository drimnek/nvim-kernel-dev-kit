# nvim-kernel-dev-kit

A standalone Neovim profile for Linux kernel development, in-tree driver work, out-of-tree kernel modules, and external folders that need to be attached to a selected kernel build context.

This project is a deployable Neovim profile, not a general-purpose Neovim distribution and not yet a standalone Neovim plugin. Its main goal is to make Linux kernel and driver work practical with `clangd`, build-derived `compile_commands.json`, scoped navigation, and explicit kernel target selection.

## Highlights

- Separate Neovim profile through `NVIM_APPNAME=nvim-kernel`.
- `knvim` launcher for kernel-oriented sessions.
- One kernel-dev UX for three contexts:
  - `in_tree`: a Linux kernel source tree.
  - `out_of_tree`: an external kernel module directory.
  - `external_dir`: any other folder attached to a kernel target.
- Global kernel target registry through `kernel-targets.json`.
- Local data-only project config through `.kdev.json`.
- `clangd` integration with build-derived `compile_commands.json`.
- Scoped navigation and grep:
  - `project`
  - `compiled`
  - `kernel`
  - `all`
- Kernel and external module build helpers.
- `compile_commands.json` and `.nvim/used-files` generation helpers.
- Telescope-based file search and grep.
- Treesitter syntax support.
- Git helpers.
- Inline Markdown rendering through `render-markdown.nvim`.

## Important behavior

`knvim` always starts the dedicated kernel profile and forces kernel-dev mode:

```bash
NVIM_APPNAME=nvim-kernel
KDEV_FORCE=1
```

That means `knvim .` can be launched from any directory.

However, the current version does **not** automatically fall back to system kernel headers such as:

```text
/lib/modules/$(uname -r)/build
```

If you start `knvim` in a random folder and no kernel target is configured, the profile still enters `external_dir` mode, but `kernel_root` and `kernel_build` remain empty. Kernel search, build, and indexing commands will then ask you to configure a target first.

This is intentional. Silent fallback to the host kernel can be misleading for embedded, vendor BSP, Android, ARM/ARM64, Yocto, or cross-compiled driver work.

## Repository layout

```text
nvim-kernel-dev-kit/
  install.sh
  uninstall.sh
  Makefile
  README.md
  LICENSE
  CHANGELOG.md
  CONTRIBUTING.md
  SECURITY.md
  CODE_OF_CONDUCT.md

  bin/
    knvim

  config/
    nvim-kernel/
      init.lua
      kernel-targets.example.json
      lua/
        core/
        plugins/
        kernel/

  examples/
    kdev.external_dir.json
    kdev.out_of_tree.json
    kdev.direct-paths.json
    clangd.kernel-template.yaml

  docs/
    architecture.md
    workflows.md
    troubleshooting.md
    licensing.md
```

## Installation

Basic install:

```bash
./install.sh
```

Install the profile and recommended Ubuntu/Debian packages:

```bash
./install.sh --install-deps
```

Force backup of an existing profile without prompting:

```bash
./install.sh --force
```

Reset Neovim data, state, and cache for this profile during installation:

```bash
./install.sh --reset-data
```

The installer creates:

```text
~/.config/nvim-kernel/
~/.local/bin/knvim
```

Make sure `~/.local/bin` is in your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Check the wrapper:

```bash
which knvim
```

## Required tools

Recommended packages:

```bash
sudo apt install -y \
  neovim git curl ripgrep fd-find jq \
  clang clangd llvm lld \
  build-essential bc bison flex libssl-dev libelf-dev \
  universal-ctags cscope global \
  gdb-multiarch trace-cmd
```

On Debian/Ubuntu, `fd` may be installed as `fdfind`. The installer creates a local `fd` symlink when possible.

## Core model

The same profile supports three kernel-aware modes.

```text
in_tree       You opened a Linux kernel tree.
out_of_tree   You opened an external kernel module directory.
external_dir  You opened any other directory, but forced it into kernel-dev mode.
```

### Context resolution

The practical resolution model is:

1. Read local project data from `.kdev.json`, if present.
2. Read global target data from `~/.config/nvim-kernel/kernel-targets.json`.
3. Apply environment overrides such as `KDEV_TARGET`, `KERNEL_ROOT`, `KERNEL_BUILD`, `KBUILD_OUTPUT`, `ARCH`, and `CROSS_COMPILE`.
4. Apply trusted `.nvim.lua` overrides if you use them.
5. Auto-detect whether the current folder looks like a kernel tree or an out-of-tree module.

The most important rule: a kernel target must be known before kernel search, external module builds, or indexing can work.

## Global kernel target registry

After installation, edit:

```text
~/.config/nvim-kernel/kernel-targets.json
```

Example for an ARM64 kernel target:

```json
{
  "default": "qemu-arm64",
  "targets": {
    "qemu-arm64": {
      "kernel_root": "/home/user/src/linux",
      "kernel_build": "/home/user/src/linux/out/qemu-arm64",
      "arch": "arm64",
      "cross_compile": "aarch64-linux-gnu-"
    }
  }
}
```

Example for a local x86_64 kernel tree:

```json
{
  "default": "local-x86",
  "targets": {
    "local-x86": {
      "kernel_root": "/home/user/src/linux",
      "kernel_build": "/home/user/src/linux/out/x86_64",
      "arch": "x86_64",
      "cross_compile": ""
    }
  }
}
```

Launch with a specific target:

```bash
KDEV_TARGET=qemu-arm64 knvim .
```

Launch with the default target:

```bash
knvim .
```

## Local project config: `.kdev.json`

A `.kdev.json` file is data-only. Prefer it over executable project-local Lua when simple configuration is enough.

External directory attached to a kernel target:

```json
{
  "target": "qemu-arm64",
  "mode": "external_dir",
  "nav_scope": "all"
}
```

Out-of-tree module:

```json
{
  "target": "qemu-arm64",
  "mode": "out_of_tree",
  "nav_scope": "project"
}
```

Direct paths without the global registry:

```json
{
  "mode": "out_of_tree",
  "kernel_root": "/home/user/src/linux",
  "kernel_build": "/home/user/src/linux/out/qemu-arm64",
  "arch": "arm64",
  "cross_compile": "aarch64-linux-gnu-",
  "nav_scope": "project"
}
```

## Quick start

Open any directory in kernel-dev mode:

```bash
knvim .
```

Inspect the resolved context:

```vim
:KernelInfo
```

Select a search scope:

```vim
:KernelScope project
:KernelScope compiled
:KernelScope kernel
:KernelScope all
```

Use the default keymaps:

```text
<leader>ki   Show resolved kernel context
<leader>kb   Build current context
<leader>kB   Clean current context
<leader>kI   Generate compile_commands.json and .nvim/used-files
<leader>kC   Build cscope database from compiled files
<leader>ks   Toggle search scope
<leader>kf   Find files in current scope
<leader>kg   Grep in current scope
<leader>kw   Grep word under cursor in current scope
<leader>mr   Toggle inline Markdown rendering
```

## Workflow: prepare a kernel build context

Before writing an out-of-tree driver, prepare the kernel that will be used as the build and indexing context.

Example:

```bash
cd ~/src/linux
make O=out/qemu-arm64 ARCH=arm64 olddefconfig
make O=out/qemu-arm64 ARCH=arm64 -j"$(nproc)" vmlinux modules
```

Then add this kernel to `~/.config/nvim-kernel/kernel-targets.json`.

For external modules, a full kernel build is safer than only `modules_prepare`, especially when `CONFIG_MODVERSIONS` is enabled and `Module.symvers` is needed.

## Workflow: start a new out-of-tree driver

This is the recommended order for starting from an empty directory.

### 1. Install the profile

```bash
unzip nvim-kernel-dev-kit-github-ready.zip
cd nvim-kernel-dev-kit
./install.sh --install-deps
```

If dependencies are already installed:

```bash
./install.sh
```

### 2. Prepare and register the kernel target

Prepare the kernel:

```bash
cd ~/src/linux
make O=out/qemu-arm64 ARCH=arm64 olddefconfig
make O=out/qemu-arm64 ARCH=arm64 -j"$(nproc)" vmlinux modules
```

Edit:

```bash
nvim ~/.config/nvim-kernel/kernel-targets.json
```

Set a target similar to:

```json
{
  "default": "qemu-arm64",
  "targets": {
    "qemu-arm64": {
      "kernel_root": "/home/user/src/linux",
      "kernel_build": "/home/user/src/linux/out/qemu-arm64",
      "arch": "arm64",
      "cross_compile": "aarch64-linux-gnu-"
    }
  }
}
```

### 3. Create a driver directory

```bash
mkdir -p ~/work/my_driver
cd ~/work/my_driver
```

Create a local project config:

```bash
cat > .kdev.json <<'EOF'
{
  "target": "qemu-arm64",
  "mode": "external_dir",
  "nav_scope": "all"
}
EOF
```

At this stage the folder is only an external directory attached to the kernel target.

### 4. Open it with the kernel profile

```bash
KDEV_TARGET=qemu-arm64 knvim .
```

Inside Neovim:

```vim
:KernelInfo
```

Expected context:

```text
mode = external_dir
project_root = /home/user/work/my_driver
kernel_root = /home/user/src/linux
kernel_build = /home/user/src/linux/out/qemu-arm64
nav_scope = all
```

### 5. Create an external module skeleton

Inside Neovim:

```vim
:KernelInitModule my_driver
```

This creates:

```text
Kbuild
Makefile
src/my_driver.c
include/my_driver.h
.clangd
```

Now change `.kdev.json` to `out_of_tree` mode:

```json
{
  "target": "qemu-arm64",
  "mode": "out_of_tree",
  "nav_scope": "project"
}
```

Restart `knvim` or run `:KernelInfo` again after reloading the file context.

### 6. Build the module

Inside Neovim:

```vim
:KernelBuild
```

For `out_of_tree` mode the helper runs the equivalent of:

```bash
make \
  -C "$kernel_root" \
  O="$kernel_build" \
  M="$PWD" \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  modules
```

The generated `Makefile` also contains a generic external-module build rule, but `:KernelBuild` uses the configured kernel target from the Neovim context.

After a successful build, the module directory will contain build artifacts such as:

```text
*.o
*.ko
*.mod
*.mod.c
.*.cmd
Module.symvers
modules.order
```

The `.cmd` files are important because the index step uses them to generate the compilation database.

### 7. Generate `compile_commands.json`

Inside Neovim:

```vim
:KernelIndex
```

For `out_of_tree` mode this generates:

```text
compile_commands.json
.nvim/used-files
```

Then restart `clangd`:

```vim
:LspRestart clangd
```

If `:LspRestart` is not available, close and reopen the project:

```bash
KDEV_TARGET=qemu-arm64 knvim .
```

At this point `clangd` has the kbuild-derived flags for your external module and navigation becomes much more accurate.

## Workflow: existing out-of-tree module

For an existing external module repository:

```bash
cd ~/work/existing_driver
KDEV_TARGET=qemu-arm64 knvim .
```

If the directory contains `Kbuild` or a `Makefile` with `obj-m`, the profile detects `out_of_tree` mode automatically unless `.kdev.json` overrides it.

Recommended commands:

```vim
:KernelInfo
:KernelBuild
:KernelIndex
:LspRestart clangd
```

If auto-detection is not enough, add `.kdev.json`:

```json
{
  "target": "qemu-arm64",
  "mode": "out_of_tree",
  "nav_scope": "project"
}
```

## Workflow: in-tree kernel development

Prepare the kernel build output first:

```bash
cd ~/src/linux
make O=out/qemu-arm64 ARCH=arm64 olddefconfig
make O=out/qemu-arm64 ARCH=arm64 -j"$(nproc)" vmlinux modules
```

Open the tree:

```bash
cd ~/src/linux
knvim .
```

Inside Neovim:

```vim
:KernelInfo
:KernelBuild
:KernelIndex
:KernelScope compiled
```

Expected mode:

```text
mode = in_tree
project_root = kernel_root
kernel_build = configured build output or out/default
```

## Workflow: arbitrary external folder

Open a vendor drop, patch queue, notes folder, reverse-engineering directory, or temporary experiment:

```bash
cd ~/work/vendor_drop
KDEV_TARGET=qemu-arm64 knvim .
```

Expected mode:

```text
mode = external_dir
project_root = current directory
kernel_root = selected target kernel source
kernel_build = selected target kernel build output
nav_scope = all
```

This gives you project + kernel search without forcing the folder to already be a kernel module.

In `external_dir` mode:

- `:KernelBuild` is disabled and tells you to create a module first.
- `:KernelIndex` is disabled because there are no kbuild-generated `.cmd` files yet.
- `project`, `kernel`, and `all` scopes are useful.
- `compiled` scope becomes useful only after a real build and index step.

To convert the folder into an external module:

```vim
:KernelInitModule my_driver
```

Then set mode to `out_of_tree`, build, and index:

```vim
:KernelBuild
:KernelIndex
:LspRestart clangd
```

## Commands

```text
:KernelInfo                Print resolved kernel-dev context.
:KernelBuild               Build current context.
:KernelClean               Clean current context.
:KernelIndex               Generate compile_commands.json and .nvim/used-files.
:KernelCscope              Build cscope database from compiled files.
:KernelScope               Toggle scope.
:KernelScope project       Use current project scope.
:KernelScope compiled      Use compiled-files-only scope.
:KernelScope kernel        Use selected kernel tree scope.
:KernelScope all           Use project + kernel scope.
:KernelInitModule <name>   Create an external module skeleton.
```

## Search scopes

```text
project    Current project directory.
compiled   Files listed in .nvim/used-files generated from compile_commands.json.
kernel     Selected kernel source tree.
all        Current project + selected kernel source tree.
```

For kernel work, `compiled` is often the most useful scope because it narrows navigation to files that were actually built for the selected configuration.

For a new out-of-tree module, `compiled` is not available immediately. Run `:KernelBuild` first, then `:KernelIndex`.

## LSP model

This profile uses `clangd`.

For accurate kernel navigation, `clangd` should read a valid `compile_commands.json` generated from the actual build context. The `:KernelIndex` command calls the kernel helper script:

```text
scripts/clang-tools/gen_compile_commands.py
```

For `in_tree` mode, the database is generated from the kernel build output directory.

For `out_of_tree` mode, the database is generated from the external module directory after a kbuild-based module build.

Without `compile_commands.json`, `clangd` may still provide fallback parsing, but results will be less accurate. In particular, it may miss generated headers, architecture-specific include paths, `CONFIG_*` state, and kbuild-specific compiler flags.

## Markdown support

This kit uses only:

```text
render-markdown.nvim
```

It renders Markdown inline inside Neovim. No browser preview plugin is included.

Use:

```vim
:RenderMarkdown toggle
```

or:

```text
<leader>mr
```

## Project-local `.nvim.lua`

This profile enables `exrc`, so Neovim can load trusted project-local config.

Prefer `.kdev.json` for simple data configuration. Use `.nvim.lua` only for repositories you trust.

Example:

```lua
vim.g.kernel_dev = {
  mode = "out_of_tree",
  kernel_root = "/home/user/src/linux",
  kernel_build = "/home/user/src/linux/out/qemu-arm64",
  arch = "arm64",
  cross_compile = "aarch64-linux-gnu-",
  nav_scope = "project",
}
```

Trust the file explicitly inside Neovim:

```vim
:trust .nvim.lua
```

## Repository maintenance

Run checks:

```bash
make check
```

Format Lua files if `stylua` is installed:

```bash
make format
```

Create an archive:

```bash
make package
```

Uninstall only the wrapper:

```bash
./uninstall.sh
```

Remove config and profile data as well:

```bash
./uninstall.sh --remove-config --remove-data
```

## Troubleshooting

See:

```text
docs/troubleshooting.md
```

Common fixes:

- If `:KernelInfo` shows no `kernel_root`, configure `kernel-targets.json`, `.kdev.json`, or environment variables.
- If `knvim` in a random folder does not find a kernel, this is expected unless a target is configured.
- If `compiled` scope fails, run `:KernelBuild` and `:KernelIndex` first.
- If `:KernelIndex` fails for an out-of-tree module, make sure `:KernelBuild` succeeded first and generated `.cmd` files.
- If `clangd` diagnostics are wrong, verify that `compile_commands.json` belongs to the current target.
- For out-of-tree modules with symbol versioning, build the full kernel first, not only `modules_prepare`.
- If you changed `.kdev.json`, restart `knvim` when in doubt.

## Roadmap

Potential future additions:

- Optional explicit system-kernel fallback through `KDEV_SYSTEM_KERNEL_FALLBACK=1`.
- Telescope target picker for `KDEV_TARGET`.
- Optional Device Tree LSP integration.
- Optional Kconfig LSP integration.
- QEMU/KGDB helper commands.
- Better multi-target compile database switching.
- Separate `kernel-dev.nvim` plugin extracted from `lua/kernel/*`.

## License

This project is licensed under `GPL-3.0-or-later`. See `LICENSE` and `docs/licensing.md`.
