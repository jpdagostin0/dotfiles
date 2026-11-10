#!/usr/bin/env bash
# Usage: ./install.sh [all|links|gnome|extensions|catppuccin]   (default: all)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {  # link <repo-file> <target>; backs up an existing real file
  local src="$DIR/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then mv "$dst" "$dst.bak-$STAMP"; echo "   backup: $dst.bak-$STAMP"; fi
  ln -sfn "$src" "$dst"; echo "   $dst -> $src"
}

links() {
  echo "==> Symlinking configs"
  link ghostty/config.ghostty      "$HOME/.config/ghostty/config.ghostty"
  link gtk/gtk-3.0/settings.ini    "$HOME/.config/gtk-3.0/settings.ini"
  link gtk/gtk-4.0/settings.ini    "$HOME/.config/gtk-4.0/settings.ini"
}

gnome() {
  echo "==> Loading dconf settings"
  dconf load /org/gnome/shell/extensions/                 < "$DIR/gnome/dconf/shell-extensions.ini"
  dconf load /org/gnome/desktop/wm/keybindings/           < "$DIR/gnome/dconf/wm-keybindings.ini"
  dconf load /org/gnome/desktop/wm/preferences/           < "$DIR/gnome/dconf/wm-preferences.ini"
  dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$DIR/gnome/dconf/media-keys.ini"
  dconf load /org/gnome/mutter/                           < "$DIR/gnome/dconf/mutter.ini"
  dconf load /org/gnome/desktop/interface/                < "$DIR/gnome/dconf/interface.ini"
}

case "${1:-all}" in
  links) links ;;
  gnome) gnome ;;
  extensions) "$DIR/scripts/extensions.sh" ;;
  catppuccin) "$DIR/scripts/catppuccin.sh" ;;
  all) links; "$DIR/scripts/catppuccin.sh"; "$DIR/scripts/extensions.sh"; gnome
       echo "Done. Log out and back in to load the shell theme and extensions." ;;
  *) echo "usage: $0 [all|links|gnome|extensions|catppuccin]"; exit 1 ;;
esac
