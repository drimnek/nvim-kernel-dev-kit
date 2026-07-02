# Architecture

`nvim-kernel-dev-kit` is a standalone Neovim profile for Linux kernel-oriented development. It is not a traditional plugin and it is not intended to replace a user's general Neovim configuration.

## Layers

```text
knvim wrapper
  -> NVIM_APPNAME=nvim-kernel
  -> ~/.config/nvim-kernel/init.lua
  -> core modules
  -> plugin setup
  -> kernel-dev modules
```

## Context resolver

The central module is:

```text
config/nvim-kernel/lua/kernel/context.lua
```

It resolves one of four modes:

```text
in_tree       Current directory is a Linux kernel tree.
out_of_tree   Current directory looks like an external kernel module.
external_dir  Current directory is arbitrary but forced into kernel-dev mode.
normal        Kernel-dev mode is not active.
```

## Kernel target registry

The global target registry is installed as:

```text
~/.config/nvim-kernel/kernel-targets.json
```

It maps a symbolic target name to:

```text
kernel_root
kernel_build
arch
cross_compile
```

This allows the same external driver directory to be attached to different kernel builds by changing `KDEV_TARGET`.

## Navigation scopes

The search module supports four scopes:

```text
project    Current project directory.
compiled   File list generated from compile_commands.json.
kernel     Selected kernel source tree.
all        Current project plus selected kernel source tree.
```

The `compiled` scope is intentionally build-derived. It is meant to reduce noise by searching only the files that belong to the active build configuration.

## LSP model

The profile uses `clangd`. Accurate kernel navigation depends on a valid `compile_commands.json` generated from the actual kernel or module build context.

For kernel code, guessed include paths are not enough. The build-derived database is the source of truth.
