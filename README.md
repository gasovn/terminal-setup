# terminal-setup

Terminal environment for Fedora Linux + KDE Plasma.

WezTerm + Fish + Starship + Neovim (LazyVim) with a one-command theme switcher.

---

## What's included

| Tool | Details |
|------|---------|
| **WezTerm** | Lua-based config with SSH connect menu, SFTP, workspaces, Ctrl+Click file:line → nvim |
| **Fish shell** | Aliases and functions built on eza, bat, ripgrep, fd, zoxide, fzf, yazi |
| **Neovim** | LazyVim-based IDE: LSP, DAP, neotest, treesitter, telescope, git — Go, TS, Python, Rust |
| **Starship** | Minimal prompt with git and language context |
| **SSH** | Grouped host management with a WezTerm connect menu |
| **Theme switcher** | Switches Gruvbox Material / Catppuccin Mocha across all tools at once |

---

## Repository structure

```
configs/
├── wezterm/      — WezTerm config (Lua modules)
├── fish/         — Fish shell (config, aliases, functions)
├── nvim/         — Neovim IDE config (LazyVim)
├── starship/     — Starship prompt config
├── ssh/          — SSH base config
└── themes/       — Theme definitions (gruvbox-material, catppuccin-mocha)
private/          — Git submodule: personal data (SSH hosts, env vars)
setup.sh          — Bootstrap: symlinks configs, installs Neovim and FiraCode
```

---

## Quick start

```bash
git clone --recurse-submodules <repo-url>
cd terminal-setup
./setup.sh
```

`setup.sh` creates symlinks from `~/.config/` to this repo, installs Neovim 0.12.2 (prebuilt, into `~/.local/`) and FiraCode Nerd Font if missing. System packages (wezterm, fish, starship, etc.) need to be installed separately — see [README-INSTALL.md](README-INSTALL.md).

---

## Private data

SSH host IPs, usernames, and personal environment variables live in the `private/` git submodule,
which is a separate private repository and not cloned publicly.

Without it everything works — the SSH host menu in WezTerm will be empty.
Template files (`hosts.example`, `ssh-hosts.example.lua`) in the public configs show the expected format.

---

## Theme switching

```bash
theme gruvbox-material
theme catppuccin-mocha
```

Switches WezTerm color scheme, Neovim colorscheme, Fish prompt colors, and Starship palette simultaneously.

---

## Russian keyboard layout

Fish functions and Neovim are configured for bilingual input:

- WezTerm uses the Kitty keyboard protocol to pass raw keycodes regardless of the active layout
- Neovim has `langmap` set so normal-mode commands work in Russian layout without switching

---

## Requirements

- Fedora Linux (tested on Fedora 41+)
- KDE Plasma

Neovim and FiraCode Nerd Font are installed automatically by `setup.sh` (Neovim from upstream prebuilt; system Neovim is left untouched).

---

## Documentation

- [README-INSTALL.md](README-INSTALL.md) — Full dependency list and manual installation steps
- [terminal-cheatsheet.md](terminal-cheatsheet.md) — WezTerm and Fish hotkeys and aliases
- [neovim-cheatsheet.md](neovim-cheatsheet.md) — Neovim keybindings
