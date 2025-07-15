# OpenCode Nix Flake

A Nix flake for [OpenCode](https://github.com/sst/opencode), an AI coding agent built for the terminal.

## Features

- Builds OpenCode from source with proper Nix integration
- Handles platform-specific dependencies (x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin)
- Automated updates via GitHub Actions
- Includes all required dependencies (Go, Bun, Node modules)

## Usage

### As a flake input

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    opencode.url = "github:ananjiani/opencode-flake";
  };

  outputs = { self, nixpkgs, opencode, ... }: {
    # Use in your system configuration
    environment.systemPackages = [
      opencode.packages.${pkgs.system}.default
    ];
  };
}
```

### Direct installation

```bash
# Install directly
nix profile install github:ananjiani/opencode-flake

# Or run without installing
nix run github:ananjiani/opencode-flake
```

## Automatic Updates

This flake is automatically updated via GitHub Actions. The workflow:

1. Checks for new OpenCode releases every 6 hours
2. Uses caching to avoid duplicate work when no updates are available
3. Updates the flake to the latest version when a new release is found
4. Creates a pull request with the changes
5. Ensures the build succeeds before proposing the update

**Update frequency**: Every 6 hours (maximum 6-hour delay from release to PR)

You can also trigger updates manually from the Actions tab with an optional force update flag.

## Manual Updates

To manually update to the latest version:

```bash
./update.sh
```

This script will:
- Fetch the latest release from GitHub
- Update the version and source hash
- Update the flake.lock
- Attempt to build and verify the update

## Platform Support

The flake supports the following platforms:
- x86_64-linux
- aarch64-linux  
- x86_64-darwin (macOS Intel)
- aarch64-darwin (macOS Apple Silicon)

Each platform has its own node_modules hash due to platform-specific dependencies.

## License

The flake packaging is MIT licensed. OpenCode itself is licensed under its own terms - see the [OpenCode repository](https://github.com/sst/opencode) for details.