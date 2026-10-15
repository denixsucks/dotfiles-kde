#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in kwinrc kwinrulesrc kglobalshortcutsrc plasma-org.kde.plasma.desktop-appletsrc \
         plasmashellrc plasmanotifyrc kdeglobals breezerc vicinae/settings.json \
         systemd/user/kwin-pidhelper.service systemd/user/mpd.socket.d/localhost.conf mpd/mpd.conf \
         mpv/mpv.conf dotfiles-kde/config.conf; do
    mkdir -p "$(dirname "$REPO/config/$f")"
    cp "$HOME/.config/$f" "$REPO/config/$f"
done

for d in kwin/scripts/cursorfollowsfocus kwin/scripts/awesomeextras kwin/scripts/keyhelp \
         plasma/plasmoids/org.denix.statusline plasma/plasmoids/org.kde.windowtitle; do
    rm -rf "${REPO:?}/local/share/$d"
    mkdir -p "$(dirname "$REPO/local/share/$d")"
    cp -r "$HOME/.local/share/$d" "$REPO/local/share/$d"
done

cp "$HOME/.local/share/applications/kitty-scratchpad.desktop" \
   "$HOME/.local/share/applications/kitty-scratchpad-rmpc.desktop" \
   "$HOME/.local/share/applications/rmpc-kitty.desktop" "$REPO/local/share/applications/"
mkdir -p "$REPO/local/bin" && cp "$HOME/.local/bin/kwin-pidhelper" "$HOME/.local/bin/dot-reload" "$REPO/local/bin/"
cp "$HOME/.local/share/icons/kde-glyph.png" "$REPO/local/share/icons/"

sed -i '/^\[services\]\[obs-[^]]*\]$/,/^$/d' "$REPO/config/kglobalshortcutsrc"
sed -i '/(OBS)/d' "$REPO/local/share/kwin/scripts/keyhelp/contents/ui/main.qml"

git -C "$REPO" status --short
