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
| `config/dotfiles-kde/config.conf`, `local/bin/dot-reload` | All tunable settings, and the command that applies them |
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

## Config

Everything tunable lives in **`~/.config/dotfiles-kde/config.conf`**. Edit it, then run **`dot-reload`**.

```ini
[features]
gaps = 6                  # pixels between tiles (0 = none)
smart_gaps = yes          # no gaps for a lone window
dim = yes                 # darken unfocused windows
dim_strength = 15
hide_cursor = yes         # hide the pointer when idle / typing
hide_cursor_after = 4
outlines = yes            # pink outline on the active window
animations = yes          # slide animation for tiling moves
focus_follows_mouse = yes
focus_delay = 250         # ms the pointer must rest before focus moves (keeps menus open)
cursor_follows_focus = yes
swallow = yes             # GUI apps started from kitty hide the terminal
back_and_forth = yes      # Meta+N on the current workspace jumps back
no_minimize = yes

[float]
class =                   # window classes that always float
title = Discord Updater, Sign in to Steam, Steam Guard, Friends List, Picture-in-Picture

[min-sizes]
ffxiv_dx11.exe = 1032x600 # apps that flicker when tiled smaller than this
```

`[float]` titles match any part of the window title. Every other window can be tiled down to 1x1; list apps in `[min-sizes]` only if they fight the tiler. To find a window's class: System Settings → Window Management → Window Rules → Add New → Detect Window Properties.

mpv is set (`config/mpv/mpv.conf`) to follow the tile size and letterbox the video instead of resizing itself.

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
| Meta+G | Group the focused window with the previous one (it hides behind it, sharing the tile) |
| Meta+Ctrl+Tab | Show the next window in the group |
| Meta+Shift+G | Ungroup |
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
