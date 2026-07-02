# Security Policy

## Supported versions

This project is early-stage. Security fixes target the current `main` branch until tagged releases are introduced.

## Reporting a security issue

Please open a private security advisory on GitHub when available, or contact the maintainer directly if a private channel is listed in the repository metadata.

## Notes for users

This project can enable Neovim project-local configuration through `exrc`. Project-local `.nvim.lua` files are executable Lua code. Use them only in repositories you trust.

For most project-specific settings, prefer `.kdev.json`, which is a data-only configuration file.
