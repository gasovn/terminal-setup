#!/usr/bin/env bash
# Bootstrap terminal environment from this repo.
# Creates symlinks from repo configs to system locations.
# Safe to re-run — uses ln -sfn (force + no-deref).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Warning ──────────────────────────────────────────────────────────

cat <<'EOF'

╔══════════════════════════════════════════════════════════════════╗
║                        ⚠  WARNING  ⚠                           ║
║                                                                  ║
║  This script will OVERWRITE your existing configs:               ║
║                                                                  ║
║    ~/.ssh/config                                                 ║
║    ~/.config/wezterm/        (entire directory)                  ║
║    ~/.config/fish/config.fish                                    ║
║    ~/.config/fish/conf.d/    (repo-managed files)               ║
║    ~/.config/fish/functions/  (repo-managed files)               ║
║    ~/.config/fish/completions/ (repo-managed files)              ║
║    ~/.config/nvim/lua/       (config + plugins)                 ║
║                                                                  ║
║  If you have local changes in these locations, back them up      ║
║  BEFORE proceeding.                                              ║
╚══════════════════════════════════════════════════════════════════╝

EOF

read -r -p "Continue? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "=== terminal-setup: creating symlinks ==="

# ── Helper ───────────────────────────────────────────────────────────

# Symlink all files from a source directory into a target directory.
# Does not recurse — only top-level files.
link_files() {
    local src="$1" dst="$2" label="$3"
    mkdir -p "$dst"
    for f in "$src"/*; do
        [ -f "$f" ] || continue
        local name
        name=$(basename "$f")
        ln -sfn "$f" "$dst/$name"
        echo "  $dst/$name → $label/$name"
    done
}

# ── SSH ──────────────────────────────────────────────────────────────

mkdir -p ~/.ssh
chmod 700 ~/.ssh

ln -sfn "$SCRIPT_DIR/configs/ssh/config" ~/.ssh/config
echo "  ~/.ssh/config → configs/ssh/config"

if [ -f "$SCRIPT_DIR/private/ssh/hosts.config" ]; then
    ln -sfn "$SCRIPT_DIR/private/ssh/hosts.config" ~/.ssh/hosts.config
    echo "  ~/.ssh/hosts.config → private/ssh/hosts.config"
else
    echo "  ~/.ssh/hosts.config — skipped (private not found)"
fi

# ── WezTerm ──────────────────────────────────────────────────────────

ln -sfn "$SCRIPT_DIR/configs/wezterm" ~/.config/wezterm
echo "  ~/.config/wezterm → configs/wezterm"

# ── Fish ─────────────────────────────────────────────────────────────

mkdir -p ~/.config/fish/conf.d
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/fish/completions

ln -sfn "$SCRIPT_DIR/configs/fish/config.fish" ~/.config/fish/config.fish
echo "  ~/.config/fish/config.fish → configs/fish/config.fish"

link_files "$SCRIPT_DIR/configs/fish/conf.d"      ~/.config/fish/conf.d      "configs/fish/conf.d"
link_files "$SCRIPT_DIR/configs/fish/functions"    ~/.config/fish/functions    "configs/fish/functions"
link_files "$SCRIPT_DIR/configs/fish/completions"  ~/.config/fish/completions  "configs/fish/completions"

if [ -f "$SCRIPT_DIR/private/fish/conf.d/private.fish" ]; then
    ln -sfn "$SCRIPT_DIR/private/fish/conf.d/private.fish" ~/.config/fish/conf.d/private.fish
    echo "  ~/.config/fish/conf.d/private.fish → private/fish/conf.d/private.fish"
else
    echo "  ~/.config/fish/conf.d/private.fish — skipped (private not found)"
fi

# ── Neovim ───────────────────────────────────────────────────────────

mkdir -p ~/.config/nvim/lua

ln -sfn "$SCRIPT_DIR/configs/nvim/lua/config" ~/.config/nvim/lua/config
echo "  ~/.config/nvim/lua/config → configs/nvim/lua/config"

ln -sfn "$SCRIPT_DIR/configs/nvim/lua/plugins" ~/.config/nvim/lua/plugins
echo "  ~/.config/nvim/lua/plugins → configs/nvim/lua/plugins"

# ── Themes ───────────────────────────────────────────────────────────
# Themes are referenced by other configs via relative paths from the repo.
# No system symlink needed — just confirm they exist.

if [ -d "$SCRIPT_DIR/configs/themes" ]; then
    echo "  configs/themes/ — available (used by wezterm, fish, nvim, starship)"
fi

echo ""
echo "Done. Restart your shell or run: source ~/.config/fish/config.fish"
