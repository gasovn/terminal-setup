#!/usr/bin/env bash
# Picker for the Ctrl+Shift+L "set tab color" WezTerm binding.
# Receives the target tab_id as $1. Shows an fzf menu with named colors
# (truecolor dots), writes the chosen palette index to
# /tmp/wezterm-tab-color-<tab_id>, then closes its own pane. The
# format-tab-title callback in appearance.lua picks up the marker on the
# next redraw and applies the color to wezterm.GLOBAL.tab_colors.
set -euo pipefail

tab_id="${1:?missing tab_id}"

# Display line (ANSI truecolor) \t palette index
# Index matches appearance.lua M.tab_palette order.
entries=(
  $'\x1b[38;2;234;150;98m1  red      ●\x1b[0m\t1'
  $'\x1b[38;2;169;182;101m2  green    ●\x1b[0m\t2'
  $'\x1b[38;2;216;166;87m3  yellow   ●\x1b[0m\t3'
  $'\x1b[38;2;125;174;163m4  blue     ●\x1b[0m\t4'
  $'\x1b[38;2;211;134;155m5  purple   ●\x1b[0m\t5'
  $'\x1b[38;2;231;138;78m6  peach    ●\x1b[0m\t6'
  $'0  reset\x1b[0m\t0'
)

selection=$(printf '%s\n' "${entries[@]}" | fzf \
  --exact \
  --no-sort \
  --layout=reverse \
  --delimiter='\t' \
  --with-nth=1 \
  --nth=1 \
  --ansi \
  --prompt='color ❯ ' \
  --border \
  --info=inline) || exit 0

[ -n "$selection" ] || exit 0
index=$(printf '%s' "$selection" | cut -f2)
echo "$index" > "/tmp/wezterm-tab-color-${tab_id}"

# Activate original tab, then close own pane — picker tab disappears
wezterm cli activate-tab --tab-id "$tab_id" --pane-id "${WEZTERM_PANE:?}" 2>/dev/null || true
wezterm cli kill-pane --pane-id "${WEZTERM_PANE:?}" 2>/dev/null || true
