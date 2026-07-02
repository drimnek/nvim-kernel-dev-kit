# Troubleshooting

## `:KernelInfo` shows missing `kernel_root`

Configure at least one of the following:

- `~/.config/nvim-kernel/kernel-targets.json`
- project `.kdev.json`
- `KERNEL_ROOT` and `KERNEL_BUILD` environment variables
- trusted project-local `.nvim.lua`

## `compiled` scope fails

Generate `.nvim/used-files` first:

```vim
:KernelBuild
:KernelIndex
:KernelScope compiled
```

## `clangd` navigation is noisy or wrong

Check that `compile_commands.json` exists in the project root and belongs to the current kernel build target.

For external modules, build the module through kbuild before generating the compilation database.

## Out-of-tree build fails

Check:

- `kernel_root` points to the kernel source tree.
- `kernel_build` points to the matching build output directory.
- `ARCH` and `CROSS_COMPILE` match the kernel build.
- the kernel was built fully when `CONFIG_MODVERSIONS` is enabled.

## Project-local `.nvim.lua` is not loaded

This profile enables `exrc`, but Neovim requires project-local config to be trusted. Run:

```vim
:trust .nvim.lua
```

Prefer `.kdev.json` when simple data configuration is enough.
