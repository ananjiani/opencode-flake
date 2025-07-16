#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest OpenCode release..."

# Get latest release version from GitHub API
LATEST_VERSION=$(curl -s https://api.github.com/repos/sst/opencode/releases/latest | jq -r .tag_name | sed 's/^v//')
CURRENT_VERSION=$(grep -E '^\s+version = "' flake.nix | sed 's/.*version = "\(.*\)";/\1/')

if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
    echo "Already at latest version: $CURRENT_VERSION"
    exit 0
fi

echo "Updating from $CURRENT_VERSION to $LATEST_VERSION"

# Update version in flake.nix
sed -i "s/version = \"$CURRENT_VERSION\";/version = \"$LATEST_VERSION\";/" flake.nix

# Try to build and capture new hashes
echo "Building to get new source hash..."
nix build --no-link .#opencode 2>&1 | tee build.log || true

# Extract source hash from error
if grep -q "got:" build.log; then
    NEW_SRC_HASH=$(grep -A1 "got:" build.log | tail -1 | xargs)
    echo "New source hash: $NEW_SRC_HASH"
    
    # Update source hash in flake.nix
    OLD_SRC_HASH=$(grep -A2 'src = pkgs.fetchFromGitHub' flake.nix | grep 'hash = ' | sed 's/.*hash = "\(.*\)";/\1/')
    sed -i "s|$OLD_SRC_HASH|$NEW_SRC_HASH|" flake.nix
fi

# Update flake.lock
echo "Updating flake.lock..."
nix flake update

# Try building again to check for node_modules hash updates
echo "Checking for node_modules hash updates..."
if ! nix build --no-link .#opencode 2>&1 | tee build2.log; then
    if grep -q "got:" build2.log && grep -q "node_modules" build2.log; then
        echo "Node modules hash changed. Manual update required for platform-specific hashes."
        echo "Check build2.log for new hashes."
    fi
fi

rm -f build.log build2.log

echo "Update complete. Please review changes and test the build."