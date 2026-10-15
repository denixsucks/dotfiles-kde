# dotfiles-kde

AwesomeWM / Hyprland-style workflow on **KDE Plasma 6 (Wayland)** with **Krohnkite** tiling, on CachyOS with two monitors.
KWin stays the compositor, so XWayland apps (Krita drag and drop, games) keep working.

## What's in here

| Path | What it is |
|---|---|
| `config/kwinrc` | Krohnkite settings, focus follows mouse, effects (outlines, move animations), plugin list |
| `config/kglobalshortcutsrc` | All keybindings below |
| `config/kwinrulesrc` | Window rules: every windowed app is resizable, Steam → workspace 10, FFXIV never maximizes |
| `config/plasma-org.kde.plasma.desktop-appletsrc`, `plasmashellrc` | The top bar on both screens |
| `config/plasmanotifyrc`, `kdeglobals`, `breezerc` | Notifications top-right, colors, fonts |
| `config/vicinae/settings.json` | Vicinae launcher above fullscreen apps |
| `local/share/kwin/scripts/cursorfollowsfocus` | Cursor jumps to the focused window on keyboard focus changes, across screens |
| `local/share/kwin/scripts/awesomeextras` | Meta+Tab previous workspace, Meta+A scratchpad, no minimizing, Meta+Ctrl+N restore |
| `local/share/kwin/scripts/keyhelp` | Meta+F1 keybinding popup, like AwesomeWM's hotkeys help |
| `local/bin/kwin-pidhelper`, `config/systemd/user/kwin-pidhelper.service` | Tiny parent-process lookup service used for window swallowing |
| `local/share/plasma/plasmoids/org.denix.statusline` | Plain-text `cpu │ gpu │ ram │ net` bar widget |
| `local/share/plasma/plasmoids/org.kde.windowtitle` | Window Title widget using the pixel font |
| `local/share/applications`, `local/share/icons` | Scratchpad / rmpc launchers, KDE glyph icon |

## Install

```bash
yay -S --needed $(cat packages.txt)
yay -S --rebuild aur/kwin-effect-rounded-corners
./install.sh
```

Build `kwin-effect-rounded-corners` from the AUR (second line), even if a repo package exists: it must be compiled against the installed KWin or it silently fails to load. Rebuild it after KWin updates if the window outlines disappear.

`install.sh` copies everything into place, backs up whatever it replaces to `~/.config/dotfiles-kde-backup-<time>/`, and reloads KWin and the bar. Log out and back in once afterwards.

Not included: the Vicinae launcher itself (installed separately) and the wallpaper image.

## Feature toggles

Turn things on and off in `features.conf`, then run `./apply-features.sh`:

| Key | Default | What it does |
|---|---|---|
| `gaps` | `6` | Pixels between tiles and screen edges (`0` = none) |
| `smart_gaps` | `yes` | No gaps when a window is alone on a screen |
| `dim` / `dim_strength` | `yes` / `15` | Darken unfocused windows (percent) |
| `hide_cursor` / `hide_cursor_after` | `yes` / `4` | Hide the mouse cursor after N idle seconds and while typing |
| `outlines` | `yes` | Pink outline on the active window |
| `animations` | `yes` | Slide animation when tiles move or resize |
| `focus_follows_mouse` | `yes` | Focus follows the pointer (`no` = click to focus) |
| `cursor_follows_focus` | `yes` | Pointer jumps to windows focused with the keyboard |
| `swallow` | `yes` | GUI apps started from kitty hide that terminal until they close |
| `back_and_forth` | `yes` | Meta+N for the workspace you're on jumps back to the previous one |
| `no_minimize` | `yes` | Windows can't stay minimized |

## Per-app minimum sizes

Every window can be tiled down to 1x1. Apps that misbehave below their own minimum (they fight the tiler and flicker) go in `min-sizes.conf`, one per line:

```
ffxiv_dx11.exe 1032 600
```

The first word is the window class. Then run:

```bash
./apply-min-sizes.sh
```

To find an app's window class: System Settings → Window Management → Window Rules → Add New → Detect Window Properties, then click the app.

## Update the repo after changing things

```bash
./sync.sh
git commit -am "update"
git push
```

## Keys

### Focus and windows

| Keys | Action |
|---|---|
| Meta+←↓↑→ | Focus by direction (crosses screens, cursor follows) |
| Meta+H / Meta+L | Focus previous / next window |
| Meta+Shift+←↓↑→ | Move window (to the other screen at the edge) |
| Meta+Ctrl+←→↑↓ | Resize: narrower / wider / taller / shorter |
| Meta+Shift+H / L / J / K | Resize (same as above, from the old rc.lua) |
| Meta+Ctrl+Return | Make master |
| Meta+Ctrl+J / K | Fewer / more master windows |
| Meta+Ctrl+Space | Float / unfloat window |
| Meta+F | Fullscreen |
| Meta+M | Maximize |
| Meta+Shift+T | Keep on top |
| Meta+O | Send window to the other screen |
| Meta+Shift+O | Swap all windows between the two screens |
| Meta+C | Center window |
| Meta+Shift+P | Pin window to every workspace |
| Meta+U | Jump to the window asking for attention |
| Meta+Q | Close window |
| Meta + left drag / right drag | Move / resize with the mouse |

### Layouts

| Keys | Action |
|---|---|
| Meta+Space / Meta+Shift+Space | Next / previous layout (Tile → Spiral → Three Column → Monocle) |
| Meta+Ctrl+T | Back to Tile |
| Meta+Shift+F | Monocle |

### Workspaces

| Keys | Action |
|---|---|
| Meta+1…9, 0 | Go to workspace 1…10 (press again to jump back) |
| Meta+Shift+1…9, 0 | Move window to workspace |
| Meta+J / Meta+K | Previous / next workspace |
| Meta+Tab | Back to the last workspace |

### Apps and session

| Keys | Action |
|---|---|
| Meta+T, Meta+Return | kitty |
| Meta+A | Dropdown scratchpad terminal |
| Meta+S | Dropdown rmpc (music) |
| Meta+W / Meta+Shift+W | Firefox / Chromium |
| Meta+D | Dolphin |
| Meta+N | rmpc |
| Meta+R, Alt+Space | Vicinae |
| Meta+Ctrl+N | Restore last minimized window |
| Meta+F1 | Keybinding popup (Esc to close) |
| Meta+X | Lock |
| Meta+Shift+Q / Meta+Shift+X / Meta+Shift+Backspace | Log out / shut down / reboot |

## Troubleshooting

- **A window won't tile:** it's floating, press Meta+Ctrl+Space.
- **A screen stopped tiling:** press Meta+Ctrl+T.
- **A new app shortcut doesn't fire:** log out and in; KDE only activates launcher shortcuts it loaded at login.
- **A game snaps back to full screen:** set it to Windowed, not Borderless Windowed, in its own settings.
