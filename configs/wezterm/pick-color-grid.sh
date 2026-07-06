#!/usr/bin/env bash
# 2D color-grid picker for the Ctrl+Shift+L "set tab color" WezTerm binding.
# Spawned in its own tab with the target tab_id as $1. Draws a matrix of
# truecolor squares — a top row of named theme colors, then a hue x lightness
# body and a grayscale row — navigated with the arrow keys or the mouse.
#   arrows / mouse move : move selection      Enter / Space / click : pick
#   #                   : type a #rrggbb      r : reset      q / Esc : cancel
# On pick/reset it writes the chosen #rrggbb (or "reset") to
# /tmp/wezterm-tab-color-<tab_id>, returns focus to the original tab and closes
# its own pane. The format-tab-title callback in appearance.lua picks up the
# marker on the next redraw.
#
# Portable to Linux/macOS bash (no bash-4-only syntax, no GUI dependency):
# needs only bash, stty and a truecolor terminal with SGR mouse reporting.
set -uo pipefail

tab_id="${1:?missing tab_id}"

# ── geometry ────────────────────────────────────────────────────────────────
CELLW=5          # 4-wide swatch + 1 gap
GRID_X0=3        # screen column (1-based) of the first swatch (2 leading spaces)
GRID_Y0=3        # screen line (1-based) of the first grid row (title + blank)

# Normalize a typed color to #rrggbb. Accepts #rgb / #rrggbb, any case, with or
# without the leading #. Returns non-zero on garbage.
normalize_hex() {
  local c
  c=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
  c="${c#\#}"
  if [[ "$c" =~ ^[0-9a-f]{6}$ ]]; then printf '#%s' "$c"; return 0; fi
  if [[ "$c" =~ ^[0-9a-f]{3}$ ]]; then
    printf '#%s%s%s%s%s%s' "${c:0:1}" "${c:0:1}" "${c:1:1}" "${c:1:1}" "${c:2:1}" "${c:2:1}"
    return 0
  fi
  return 1
}

# HSL(percent) -> R G B (0..255), integer math scaled by 1000.
hsl_rgb() {
  local H=$1 S=$(( $2 * 10 )) L=$(( $3 * 10 ))
  local d=$(( 2 * L - 1000 )); if [ $d -lt 0 ]; then d=$(( -d )); fi
  local C=$(( (1000 - d) * S / 1000 ))
  local t=$(( H % 120 )); local a=$(( t - 60 )); if [ $a -lt 0 ]; then a=$(( -a )); fi
  local X=$(( C * (60 - a) / 60 ))
  local m=$(( L - C / 2 ))
  local r g b
  case $(( H / 60 )) in
    0) r=$C; g=$X; b=0 ;;
    1) r=$X; g=$C; b=0 ;;
    2) r=0;  g=$C; b=$X ;;
    3) r=0;  g=$X; b=$C ;;
    4) r=$X; g=0;  b=$C ;;
    *) r=$C; g=0;  b=$X ;;
  esac
  R=$(( ( (r + m) * 255 + 500 ) / 1000 ))
  G=$(( ( (g + m) * 255 + 500 ) / 1000 ))
  B=$(( ( (b + m) * 255 + 500 ) / 1000 ))
}

# ── build cells (flat arrays + per-row start/length) ────────────────────────
cell_r=(); cell_g=(); cell_b=(); cell_hex=(); cell_label=()
rowstart=(); rowlen=(); rows=0
push_cell() { cell_r+=("$1"); cell_g+=("$2"); cell_b+=("$3"); cell_hex+=("$4"); cell_label+=("$5"); }

# Row 0 — named theme colors (Gruvbox Material).
theme_hex=('#ea6962' '#a9b665' '#d8a657' '#7daea3' '#d3869b' '#e78a4e')
theme_name=('red' 'green' 'yellow' 'blue' 'purple' 'peach')
rowstart+=("${#cell_hex[@]}"); rowlen+=("${#theme_hex[@]}"); rows=$(( rows + 1 ))
for i in "${!theme_hex[@]}"; do
  h=${theme_hex[i]}
  push_cell "$((16#${h:1:2}))" "$((16#${h:3:2}))" "$((16#${h:5:2}))" "$h" "${theme_name[i]}"
done

# Rows 1..N — hue (12 columns) x lightness.
cols=12; SAT=68; Lrows=(88 78 68 58 47 37 27)
for Lp in "${Lrows[@]}"; do
  rowstart+=("${#cell_hex[@]}"); rowlen+=("$cols"); rows=$(( rows + 1 ))
  for (( c = 0; c < cols; c++ )); do
    hsl_rgb $(( c * 30 )) "$SAT" "$Lp"
    push_cell "$R" "$G" "$B" "$(printf '#%02x%02x%02x' "$R" "$G" "$B")" ''
  done
done

# Last row — grayscale ramp (12 columns).
rowstart+=("${#cell_hex[@]}"); rowlen+=("$cols"); rows=$(( rows + 1 ))
for (( c = 0; c < cols; c++ )); do
  v=$(( (255 * c + (cols - 1) / 2) / (cols - 1) ))
  push_cell "$v" "$v" "$v" "$(printf '#%02x%02x%02x' "$v" "$v" "$v")" ''
done

# ── terminal setup ──────────────────────────────────────────────────────────
if ! { exec 3<>/dev/tty; } 2>/dev/null; then echo 'no tty' >&2; exit 1; fi
saved=$(stty -g <&3)
mouse_on()  { printf '\033[?1000h\033[?1006h' >&3; }
mouse_off() { printf '\033[?1000l\033[?1006l' >&3; }
cleanup() {
  mouse_off
  stty "$saved" <&3 2>/dev/null || true
  printf '\033[?25h\033[0m' >&3 2>/dev/null || true
}
trap cleanup EXIT
stty -echo -icanon min 0 time 1 <&3
printf '\033[?25l\033[2J' >&3
mouse_on

row=0; col=0; value=''

idx() { echo $(( rowstart[row] + col )); }

goto_row() {
  local nr=$1
  if [ $nr -ge 0 ] && [ $nr -lt $rows ]; then
    row=$nr
    local rl=${rowlen[row]}
    if [ $col -ge $rl ]; then col=$(( rl - 1 )); fi
  fi
}

draw() {
  printf '\033[H' >&3
  printf '\033[1m palette\033[0m  \342\206\221\342\206\223\342\206\220\342\206\222/mouse pick \302\267 # hex \302\267 r reset \302\267 q quit\033[K\r\n\r\n' >&3
  local rr cc i r g b mk l
  for (( rr = 0; rr < rows; rr++ )); do
    printf '  ' >&3
    for (( cc = 0; cc < rowlen[rr]; cc++ )); do
      i=$(( rowstart[rr] + cc ))
      r=${cell_r[i]}; g=${cell_g[i]}; b=${cell_b[i]}
      if [ $rr -eq $row ] && [ $cc -eq $col ]; then
        l=$(( 299 * r + 587 * g + 114 * b ))
        if [ $l -gt 140000 ]; then mk=0; else mk=255; fi
        printf '\033[48;2;%d;%d;%dm\033[38;2;%d;%d;%dm \342\227\217  \033[0m ' "$r" "$g" "$b" "$mk" "$mk" "$mk" >&3
      else
        printf '\033[48;2;%d;%d;%dm    \033[0m ' "$r" "$g" "$b" >&3
      fi
    done
    printf '\033[K\r\n' >&3
  done
  i=$(( rowstart[row] + col ))
  l=${cell_label[i]}
  if [ -n "$l" ]; then l=" ($l)"; fi
  printf '\r\n  selected: \033[48;2;%d;%d;%dm    \033[0m  %s%s\033[K\r\n' \
    "${cell_r[i]}" "${cell_g[i]}" "${cell_b[i]}" "${cell_hex[i]}" "$l" >&3
}

# Prompt for a typed hex in cooked mode; on success sets `value` and returns 0.
hex_prompt() {
  mouse_off
  stty "$saved" <&3
  printf '\033[?25h' >&3
  printf '\r\n  hex \342\235\257 #' >&3
  local line hv
  IFS= read -r line <&3 || line=''
  stty -echo -icanon min 0 time 1 <&3
  printf '\033[?25l' >&3
  mouse_on
  if hv=$(normalize_hex "$line"); then value="$hv"; return 0; fi
  return 1
}

# Map a click at screen (x,y) to a cell; on hit sets row/col and returns 0.
mouse_hit() {
  local x=$1 y=$2
  local rr=$(( y - GRID_Y0 ))
  if [ $rr -lt 0 ] || [ $rr -ge $rows ]; then return 1; fi
  local cc=$(( (x - GRID_X0) / CELLW ))
  if [ $cc -lt 0 ] || [ $cc -ge ${rowlen[rr]} ]; then return 1; fi
  row=$rr; col=$cc; return 0
}

draw
while :; do
  if ! IFS= read -rsn1 k <&3; then continue; fi
  if [ "$k" = $'\033' ]; then
    IFS= read -rsn1 c1 <&3 || c1=''
    if [ -z "$c1" ]; then value=''; break; fi          # bare Esc → cancel
    IFS= read -rsn1 c2 <&3 || c2=''
    if [ "$c2" = '<' ]; then                            # SGR mouse: [<b;x;y(M|m)
      seq=''
      while IFS= read -rsn1 ch <&3; do
        case "$ch" in M|m) break ;; esac
        seq="$seq$ch"
      done
      if [ "${ch:-}" = 'M' ]; then                      # button press only
        IFS=';' read -r mb mx my <<<"$seq"
        if [ "${mb:-}" = '0' ] && mouse_hit "${mx:-0}" "${my:-0}"; then
          value=${cell_hex[$(idx)]}; break
        fi
      fi
      draw
    else
      case "$c1$c2" in
        '[A'|'OA') goto_row $(( row - 1 )) ;;
        '[B'|'OB') goto_row $(( row + 1 )) ;;
        '[C'|'OC') if [ $col -lt $(( rowlen[row] - 1 )) ]; then col=$(( col + 1 )); fi ;;
        '[D'|'OD') if [ $col -gt 0 ]; then col=$(( col - 1 )); fi ;;
        *) : ;;
      esac
      draw
    fi
  elif [ -z "$k" ] || [ "$k" = $'\r' ] || [ "$k" = ' ' ]; then
    value=${cell_hex[$(idx)]}; break
  elif [ "$k" = '#' ]; then
    if hex_prompt; then break; fi
    draw
  elif [ "$k" = r ] || [ "$k" = R ]; then
    value='reset'; break
  elif [ "$k" = q ] || [ "$k" = Q ]; then
    value=''; break
  fi
done

cleanup
trap - EXIT

if [ -n "$value" ]; then
  echo "$value" > "/tmp/wezterm-tab-color-${tab_id}"
fi
wezterm cli activate-tab --tab-id "$tab_id" --pane-id "${WEZTERM_PANE:?}" 2>/dev/null || true
wezterm cli kill-pane --pane-id "${WEZTERM_PANE:?}" 2>/dev/null || true
