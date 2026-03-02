# Terminal Themes

Switch themes with `theme <name>` in Fish shell.

## Commands

```
theme              Show current theme
theme list         List available themes
theme <name>       Switch to a theme
```

## Adding a New Theme

1. Create a directory: `~/.config/themes/<name>/`

2. Add these 6 files:

| File | Purpose |
|------|---------|
| `theme.conf` | Metadata (name, scheme names) |
| `wezterm-palette.lua` | `M.colors` table + `M.scheme` for appearance.lua |
| `wezterm-statusbar.lua` | `local c` table for statusbar.lua |
| `nvim-colorscheme.lua` | Full lazy.nvim plugin spec (copied as-is) |
| `fish-colors.fish` | `set -g fish_color_*` variables (copied as-is) |
| `starship-palette.toml` | Full `starship.toml` (replaced entirely — themes can have different layouts) |

3. **Semantic color names** (WezTerm): Use the same names as Catppuccin (teal, blue, green, surface0, base, etc.) so color references in statusbar.lua work without changes.

4. **Starship palette**: Can use any naming convention since the entire file is replaced. Each theme owns its full starship config including format strings and layout.

5. Test: `theme <name>`

## How It Works

Two config files use `THEME: BEGIN/END` markers for inline replacement:
- `~/.config/wezterm/appearance.lua` — palette + color scheme name
- `~/.config/wezterm/statusbar.lua` — statusbar color table

Three files are replaced entirely:
- `~/.config/starship.toml` — full config (layout + palette)
- `~/.config/nvim/lua/plugins/colorscheme.lua`
- `~/.config/fish/conf.d/theme.fish`

Current theme name is stored in `~/.config/current-theme`.
