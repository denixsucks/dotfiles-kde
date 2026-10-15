#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config/dotfiles-kde-backup-$(date +%Y%m%d-%H%M%S)"

install_file() {
    local src="$1" dst="$2"
    if [[ -e "$dst" ]]; then
        mkdir -p "$BACKUP/$(dirname "${dst#"$HOME"/}")"
        cp -a "$dst" "$BACKUP/${dst#"$HOME"/}"
    fi
    mkdir -p "$(dirname "$dst")"
    sed "s#/home/denix#$HOME#g" "$src" > "$dst" 2>/dev/null || cp -a "$src" "$dst"
}

echo "==> Stopping plasmashell so it does not overwrite the panel config"
systemctl --user stop plasma-plasmashell 2>/dev/null || true

echo "==> Configs -> ~/.config"
while IFS= read -r -d '' f; do
    rel="${f#"$REPO/config/"}"
    install_file "$f" "$HOME/.config/$rel"
done < <(find "$REPO/config" -type f -print0)

echo "==> KWin scripts, plasmoids, launchers, icon -> ~/.local/share"
while IFS= read -r -d '' f; do
    rel="${f#"$REPO/local/share/"}"
    if [[ "$f" == *.png ]]; then
        mkdir -p "$(dirname "$HOME/.local/share/$rel")"; cp -a "$f" "$HOME/.local/share/$rel"
    else
        install_file "$f" "$HOME/.local/share/$rel"
    fi
done < <(find "$REPO/local/share" -type f -print0)
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "==> Helpers -> ~/.local/bin"
mkdir -p "$HOME/.local/bin"
install -m 755 "$REPO/local/bin/kwin-pidhelper" "$HOME/.local/bin/kwin-pidhelper"
systemctl --user daemon-reload
systemctl --user enable --now kwin-pidhelper 2>/dev/null || true

"$REPO/apply-features.sh" >/dev/null || true

echo "==> Reloading KWin and starting plasmashell"
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
systemctl --user start plasma-plasmashell 2>/dev/null || true
systemctl --user restart vicinae 2>/dev/null || true

[[ -d "$BACKUP" ]] && echo "Backed up replaced files to $BACKUP"
echo "Done. Log out and back in once so KWin loads the scripts and every shortcut fresh."
