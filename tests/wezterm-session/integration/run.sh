#!/usr/bin/env bash
# Round trip on a real wezterm: build a layout, snapshot it, restore it in a
# second instance, snapshot again, compare. Needs a graphical session.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

export SESSION_REPO="$repo"
export SESSION_OUT="$work"
export SESSION_STATE="$work/state"

run_phase() {
    timeout 40 wezterm --config-file "$repo/tests/wezterm-session/integration/$1" \
        start -- bash -c 'sleep 6' >"$work/$1.log" 2>&1 || true
}

run_phase phase_a.lua
run_phase phase_b.lua

for f in a.txt b.txt; do
    if [ ! -f "$work/$f" ]; then
        echo "FAIL: $f was never written; see $work/phase_*.log"
        cat "$work"/phase_*.log
        exit 1
    fi
done

if ! diff -u "$work/a.txt" "$work/b.txt"; then
    echo 'FAIL: the restored session differs from the captured one'
    exit 1
fi

echo 'integration ok: restored session matches the captured one'
