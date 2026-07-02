# Changelog

All notable changes to this project will be documented in this file.

This project follows a simple human-readable changelog format and uses semantic-ish version names for releases.

## [Unreleased]

### Added

- GitHub-ready repository layout.
- GPL-3.0-or-later licensing metadata.
- `Makefile` targets for install, lint, format, package, and cleanup.
- GitHub Actions workflow for shell and Lua syntax checks.
- Repository documentation under `docs/`.
- `uninstall.sh` helper.

## [0.1.0] - 2026-06-30

### Added

- Standalone `nvim-kernel` profile.
- `knvim` wrapper using `NVIM_APPNAME=nvim-kernel`.
- Kernel context detection for `in_tree`, `out_of_tree`, and `external_dir` modes.
- Global kernel target registry.
- Local `.kdev.json` support.
- Build helpers for in-tree kernel and out-of-tree modules.
- `compile_commands.json` and `.nvim/used-files` generation.
- Scoped file search and grep: `project`, `compiled`, `kernel`, and `all`.
- `clangd` LSP configuration.
- Telescope, Treesitter, Git, diagnostics, and inline Markdown rendering.
