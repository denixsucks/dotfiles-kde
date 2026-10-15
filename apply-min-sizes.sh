#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="${1:-$REPO/min-sizes.conf}"
RC=kwinrulesrc
GLOBAL=c0a1b2c3-all0-0000-0000-resizeanything

rule_id() { printf 'minsize-%s' "$(printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '_')"; }

old_rules="$(kreadconfig6 --file $RC --group General --key rules)"
keep=()
IFS=',' read -ra ids <<< "$old_rules"
for id in "${ids[@]}"; do
    [[ -z "$id" || "$id" == minsize-* || "$id" == "$GLOBAL" ]] && continue
    keep+=("$id")
done

for group in $(grep -o '^\[minsize-[^]]*\]' "$HOME/.config/$RC" | tr -d '[]'); do
    for key in $(sed -n "/^\[$group\]/,/^\[/p" "$HOME/.config/$RC" | grep '=' | cut -d= -f1); do
        kwriteconfig6 --file $RC --group "$group" --key "$key" --delete
    done
done

added=()
while read -r cls w h _; do
    [[ -z "${cls:-}" ]] && continue
    id="$(rule_id "$cls")"
    kwriteconfig6 --file $RC --group "$id" --key Description "Minimum size for $cls"
    kwriteconfig6 --file $RC --group "$id" --key wmclass "$cls"
    kwriteconfig6 --file $RC --group "$id" --key wmclassmatch 1
    kwriteconfig6 --file $RC --group "$id" --key minsize "$w,$h"
    kwriteconfig6 --file $RC --group "$id" --key minsizerule 2
    added+=("$id")
    echo "$cls -> ${w}x${h}"
done < "$LIST"

all=("${keep[@]}" "${added[@]}" "$GLOBAL")
kwriteconfig6 --file $RC --group General --key rules "$(IFS=,; echo "${all[*]}")"
kwriteconfig6 --file $RC --group General --key count "${#all[@]}"
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
echo "Everything else: 1x1"
