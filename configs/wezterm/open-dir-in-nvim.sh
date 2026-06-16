#!/usr/bin/env bash
# Picker for the Ctrl+Shift+E "open directory in nvim" WezTerm binding.
# Receives base directories as arguments, lists their immediate subdirectories
# (one level deep, hidden dirs skipped), groups them by parent directory and
# lets the user pick one via fzf. The query is split on spaces into AND terms;
# --exact keeps each term a contiguous substring (no per-letter fuzzy matching).
# On selection, opens nvim in the chosen directory in this tab.
set -euo pipefail

entries=()
for base in "$@"; do
  [ -d "$base" ] || continue
  parent=$(basename "$base")
  while IFS= read -r dir; do
    name=$(basename "$dir")
    label="$parent ▸ $name"
    branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
    [ -n "$branch" ] && label="$label ($branch)"
    entries+=("$label"$'\t'"$dir")
  done < <(find "$base" -maxdepth 1 -mindepth 1 -type d -not -name '.*' | sort)
done

[ "${#entries[@]}" -gt 0 ] || exit 0

selection=$(printf '%s\n' "${entries[@]}" | fzf \
  --exact \
  --no-sort \
  --layout=reverse \
  --delimiter='\t' \
  --with-nth=1 \
  --nth=1 \
  --prompt='nvim ❯ ' \
  --border \
  --info=inline) || exit 0

[ -n "$selection" ] || exit 0
dir=$(printf '%s' "$selection" | cut -f2)
cd "$dir" && exec nvim .
