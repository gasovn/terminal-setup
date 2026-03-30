#!/usr/bin/env bash
# Symlink configs from this repo to system locations.
# Run once after cloning. Safe to re-run — uses ln -sfn (force + no-deref).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== terminal-setup: creating symlinks ==="

# ── SSH ──────────────────────────────────────────────────────────────
mkdir -p ~/.ssh
chmod 700 ~/.ssh

ln -sfn "$SCRIPT_DIR/configs/ssh/config" ~/.ssh/config
echo "  ~/.ssh/config → configs/ssh/config"

if [ -f "$SCRIPT_DIR/private/ssh/hosts.config" ]; then
    ln -sfn "$SCRIPT_DIR/private/ssh/hosts.config" ~/.ssh/hosts.config
    echo "  ~/.ssh/hosts.config → private/ssh/hosts.config"
else
    echo "  ~/.ssh/hosts.config — skipped (private/ssh/hosts.config not found)"
fi

# ── Fish ─────────────────────────────────────────────────────────────
mkdir -p ~/.config/fish/conf.d

if [ -f "$SCRIPT_DIR/private/fish/conf.d/private.fish" ]; then
    ln -sfn "$SCRIPT_DIR/private/fish/conf.d/private.fish" ~/.config/fish/conf.d/private.fish
    echo "  ~/.config/fish/conf.d/private.fish → private/fish/conf.d/private.fish"
else
    echo "  ~/.config/fish/conf.d/private.fish — skipped (not found)"
fi

echo ""
echo "Done. Restart your shell or run: source ~/.config/fish/config.fish"
