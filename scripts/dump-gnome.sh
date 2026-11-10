#!/usr/bin/env bash
# Re-export current GNOME settings into the repo (run after changing things in GNOME).
set -euo pipefail
D="$(cd "$(dirname "$0")/.." && pwd)/gnome/dconf"
dconf dump /org/gnome/desktop/wm/keybindings/            > "$D/wm-keybindings.ini"
dconf dump /org/gnome/desktop/wm/preferences/            > "$D/wm-preferences.ini"
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$D/media-keys.ini"
dconf dump /org/gnome/mutter/                            > "$D/mutter.ini"
dconf dump /org/gnome/desktop/interface/                 > "$D/interface.ini"
# Only keep settings for extensions listed in extensions.txt
for s in dash-to-dock rounded-windows simple-tiling/domoel space-bar/appearance user-theme wack-lockscreen-clock; do
  echo "[$s]"; dconf dump "/org/gnome/shell/extensions/$s/" | sed '1d'; echo
done | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "$D/shell-extensions.ini"
git -C "$D" diff --stat
