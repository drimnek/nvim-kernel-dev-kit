# Contributing

Thank you for considering a contribution to `nvim-kernel-dev-kit`.

This project is intentionally small: it is a standalone Neovim profile for Linux kernel development workflows, not a general-purpose Neovim distribution.

## Scope

Good contributions include:

- safer kernel context detection;
- better out-of-tree module workflows;
- better `compile_commands.json` generation helpers;
- improved documentation and troubleshooting;
- non-invasive LSP improvements;
- small quality-of-life additions for kernel, driver, BSP, and embedded Linux work.

Out of scope by default:

- turning this into a large general-purpose IDE distribution;
- adding many language ecosystems unrelated to kernel work;
- adding browser-based Markdown preview;
- adding plugin-heavy UI layers by default.

## Development setup

Clone the repository and run:

```bash
make check
```

Optional formatting:

```bash
make format
```

Install locally for manual testing:

```bash
./install.sh --force
knvim .
```

## Style

- Keep Lua modules small and explicit.
- Prefer data-only project configuration through `.kdev.json`.
- Keep executable project-local `.nvim.lua` optional and documented as trusted-only.
- Keep defaults conservative.
- Avoid hardcoded private paths in committed files.

## Licensing

By contributing, you agree that your contribution is licensed under the same project license: `GPL-3.0-or-later`.
