# Workflows

## In-tree kernel workflow

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

Use this when editing code directly inside the Linux kernel tree.

## Out-of-tree module workflow

```bash
cd ~/work/my_driver
KDEV_TARGET=qemu-arm64 knvim .
```

The directory should contain `Kbuild` or `Makefile` with `obj-m`.

Inside Neovim:

```vim
:KernelBuild
:KernelIndex
```

The build command uses kbuild with `M=<driver_root>`.

## External directory workflow

```bash
cd ~/work/vendor_drop
KDEV_TARGET=qemu-arm64 knvim .
```

This is useful when the directory is not a kernel tree and not yet an external module, but you still want kernel-aware navigation and grep.

You can later turn it into a module skeleton:

```vim
:KernelInitModule my_driver
:KernelBuild
:KernelIndex
```

## Multiple targets

Edit:

```text
~/.config/nvim-kernel/kernel-targets.json
```

Then launch with:

```bash
KDEV_TARGET=vendor-imx8 knvim .
KDEV_TARGET=qemu-arm64 knvim .
```

## tmux usage

A typical tmux layout is:

```text
window 1: knvim .
window 2: make / test / deploy commands
window 3: dmesg -w / journalctl / ssh target
window 4: ftrace / dynamic_debug / trace-cmd
```

`tmux` is intentionally not embedded into the Neovim profile. It remains a separate workflow tool.
