#!/usr/bin/env bash
# Bootstrap terminal environment from this repo.
# Creates symlinks from repo configs to system locations.
# Safe to re-run — uses ln -sfn (force + no-deref).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Pinned Neovim release: nvim-treesitter master requires >= 0.12 and
# Fedora ships 0.11.6, so we install the official prebuilt into ~/.local/
# and a symlink in ~/.local/bin/nvim wins over /usr/bin/nvim in PATH.
# Bump this when upstream cuts a new release we want.
NVIM_VERSION="v0.12.2"

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
║    ~/.config/nvim/init.lua                                       ║
║    ~/.config/nvim/lazy-lock.json                                 ║
║    ~/.config/nvim/lua/       (config + plugins)                  ║
║    ~/.config/themes/         (entire directory)                  ║
║    ~/.config/starship.toml                                       ║
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

# Remove existing directories so ln -sfn creates a symlink at the path
# (ln -sfn into an existing directory creates a symlink *inside* it)
[ -d ~/.config/nvim/lua/config ] && [ ! -L ~/.config/nvim/lua/config ] && rm -rf ~/.config/nvim/lua/config
[ -d ~/.config/nvim/lua/plugins ] && [ ! -L ~/.config/nvim/lua/plugins ] && rm -rf ~/.config/nvim/lua/plugins

ln -sfn "$SCRIPT_DIR/configs/nvim/init.lua" ~/.config/nvim/init.lua
echo "  ~/.config/nvim/init.lua → configs/nvim/init.lua"

ln -sfn "$SCRIPT_DIR/configs/nvim/lazy-lock.json" ~/.config/nvim/lazy-lock.json
echo "  ~/.config/nvim/lazy-lock.json → configs/nvim/lazy-lock.json"

ln -sfn "$SCRIPT_DIR/configs/nvim/lua/config" ~/.config/nvim/lua/config
echo "  ~/.config/nvim/lua/config → configs/nvim/lua/config"

ln -sfn "$SCRIPT_DIR/configs/nvim/lua/plugins" ~/.config/nvim/lua/plugins
echo "  ~/.config/nvim/lua/plugins → configs/nvim/lua/plugins"

# ── Themes ───────────────────────────────────────────────────────────
# theme.fish reads themes from ~/.config/themes/<name>/.

mkdir -p ~/.config

ln -sfn "$SCRIPT_DIR/configs/themes" ~/.config/themes
echo "  ~/.config/themes → configs/themes"

# Default theme on first install. Existing user choice is preserved.
if [ ! -f ~/.config/current-theme ]; then
    echo "gruvbox-material" > ~/.config/current-theme
    echo "  ~/.config/current-theme → gruvbox-material (default)"
fi

# ── Starship ─────────────────────────────────────────────────────────
# Note: `theme <name>` overwrites this file with the theme's
# starship-palette.toml — through the symlink, into the repo.

ln -sfn "$SCRIPT_DIR/configs/starship/starship.toml" ~/.config/starship.toml
echo "  ~/.config/starship.toml → configs/starship/starship.toml"

# ── Neovim (prebuilt tarball) ────────────────────────────────────────
# Install from upstream release rather than dnf to keep up with plugin
# requirements (lazy.nvim, nvim-treesitter, etc. drop old nvim quickly).

nvim_dir="$HOME/.local/nvim"
nvim_bin="$HOME/.local/bin/nvim"
current_nvim=""
[ -x "$nvim_bin" ] && current_nvim=$("$nvim_bin" --version 2>/dev/null | awk 'NR==1{print $2}')

if [ "$current_nvim" = "$NVIM_VERSION" ]; then
    echo "  Neovim $NVIM_VERSION — already installed"
else
    echo "  Neovim $NVIM_VERSION — installing…"
    tmp=$(mktemp -d)
    url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
    if curl -fsSL -o "$tmp/nvim.tar.gz" "$url" \
       && rm -rf "$nvim_dir" \
       && mkdir -p "$nvim_dir" \
       && tar -xzf "$tmp/nvim.tar.gz" -C "$nvim_dir" --strip-components=1 \
       && mkdir -p "$HOME/.local/bin" \
       && ln -sfn "$nvim_dir/bin/nvim" "$nvim_bin"; then
        echo "  $nvim_bin → $nvim_dir/bin/nvim"
    else
        echo "  Neovim install failed (network or release missing)" >&2
    fi
    rm -rf "$tmp"
fi

# ── Fonts: FiraCode Nerd Font ────────────────────────────────────────
# WezTerm requires this font; install if missing.

# grep -q closes the pipe early -> fc-list gets SIGPIPE; with `pipefail`
# this would falsely look like "not found", so check via match count instead.
if [ "$(fc-list 2>/dev/null | grep -ci "FiraCode Nerd")" -gt 0 ]; then
    echo "  FiraCode Nerd Font — already installed"
else
    echo "  FiraCode Nerd Font — installing…"
    fonts_dir=~/.local/share/fonts
    mkdir -p "$fonts_dir"
    tmp=$(mktemp -d)
    if curl -fsSL -o "$tmp/FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip \
       && unzip -q "$tmp/FiraCode.zip" -d "$tmp/FiraCode" \
       && cp "$tmp"/FiraCode/*.ttf "$fonts_dir/" \
       && fc-cache -f >/dev/null; then
        echo "  FiraCode Nerd Font → $fonts_dir/"
    else
        echo "  FiraCode Nerd Font — install failed (check network); set font manually" >&2
    fi
    rm -rf "$tmp"
fi

echo ""
echo "Done. Restart your shell or run: source ~/.config/fish/config.fish"
