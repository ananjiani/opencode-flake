# OpenCode Flake Development Guide

## Build Commands
- Build: `nix build .#opencode`
- Test build: `nix build .#opencode --no-link`
- Update flake: `nix flake update`
- Update to latest OpenCode: `./update.sh`

## Code Style
- Shell scripts: Use bash with `set -euo pipefail`
- Nix: Follow nixpkgs conventions, use `pkgs.lib` functions
- Indentation: 2 spaces for Nix files
- Always use `rg` instead of `grep`, `fd` instead of `find`
- Use `jq` for JSON processing

## Project Structure
- `flake.nix`: Main Nix flake definition
- `update.sh`: Script to update OpenCode version
- Platform-specific hashes in `opencode-node-modules-hash`
- Supports: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin

## Important Notes
- Node modules hashes are platform-specific and must be updated per platform
- GitHub Actions automatically checks for updates weekly
- Never commit build artifacts (result, result-*, build.log)