#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${1:-$REPO/features.conf}"

declare -A F
while IFS='=' read -r key value; do
    key="${key//[[:space:]]/}"; value="${value//[[:space:]]/}"
    [[ -z "$key" || "$key" == \#* ]] && continue
    F[$key]="$value"
done < "$CONF"

yes() { [[ "${F[$1]:-yes}" =~ ^(yes|true|on|1)$ ]]; }
bool() { yes "$1" && echo true || echo false; }
kw() { kwriteconfig6 --file kwinrc --group "$1" --key "$2" "$3"; }
q() { qdbus6 org.kde.KWin "$@" >/dev/null 2>&1 || true; }

effect() {
    kw Plugins "${1}Enabled" "$2"
    if [[ "$2" == true ]]; then q /Effects org.kde.kwin.Effects.loadEffect "$1"; q /Effects org.kde.kwin.Effects.reconfigureEffect "$1"
    else q /Effects org.kde.kwin.Effects.unloadEffect "$1"; fi
}

gap="${F[gaps]:-6}"
for side in Left Right Top Bottom Between; do kw Script-krohnkite "screenGap$side" "$gap"; done
kw Script-krohnkite soleWindowNoGaps "$(bool smart_gaps)"

kw Effect-diminactive Strength "${F[dim_strength]:-15}"
effect diminactive "$(bool dim)"
kw Effect-hidecursor InactivityDuration "${F[hide_cursor_after]:-4}"
effect hidecursor "$(bool hide_cursor)"
effect kwin4_effect_shapecorners "$(bool outlines)"
effect kwin4_effect_geometry_change "$(bool animations)"

if yes focus_follows_mouse; then kw Windows FocusPolicy FocusFollowsMouse; else kw Windows FocusPolicy ClickToFocus; fi
kw Plugins cursorfollowsfocusEnabled "$(bool cursor_follows_focus)"

kw Script-awesomeextras swallow "$(bool swallow)"
kw Script-awesomeextras backAndForth "$(bool back_and_forth)"
kw Script-awesomeextras noMinimize "$(bool no_minimize)"

for script in krohnkite awesomeextras; do
    kw Plugins "${script}Enabled" false
done
q /KWin reconfigure; sleep 1
for script in krohnkite awesomeextras; do
    kw Plugins "${script}Enabled" true
done
q /KWin reconfigure

for k in "${!F[@]}"; do printf '%s=%s\n' "$k" "${F[$k]}"; done | sort
echo "Applied."
