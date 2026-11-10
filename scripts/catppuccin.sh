#!/usr/bin/env bash
# Catppuccin Mocha (Mauve, dark) GTK + GNOME Shell theme, Papirus-Dark icons
# with Catppuccin folder colours. Everything installs to $HOME, no root needed
# (except optionally `apt install sassc`).
set -euo pipefail
FLAVOR_ACCENT="${ACCENT:-mauve}"          # theme accent
FOLDERS="${FOLDERS:-cat-mocha-mauve}"     # papirus folder colour
THEME="Catppuccin-${FLAVOR_ACCENT^}-Dark"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# --- sassc (needed to build the theme) ---------------------------------------
if ! command -v sassc >/dev/null; then
  if sudo -n true 2>/dev/null; then
    sudo apt-get install -y sassc
  else
    # No root: use libsass' pysassc behind a sassc-compatible shim.
    if ! command -v pysassc >/dev/null; then
      if command -v uv >/dev/null; then uv tool install libsass
      else python3 -m pip install --user libsass; fi
    fi
    mkdir -p "$TMP/bin"
    cat > "$TMP/bin/sassc" <<'EOF'
#!/bin/bash
a=(); for x in "$@"; do [[ $x == -M ]] || a+=("$x"); done
exec pysassc "${a[@]}"
EOF
    chmod +x "$TMP/bin/sassc"; export PATH="$TMP/bin:$HOME/.local/bin:$PATH"
  fi
fi

# --- GTK / Shell theme -------------------------------------------------------
echo "==> Building $THEME"
git clone -q --depth 1 https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme.git "$TMP/gtk"
# The installer ends with an interactive prompt that fails without a TTY;
# the theme is already installed by then, so tolerate that exit code.
(cd "$TMP/gtk/themes" && ./install.sh -a "$FLAVOR_ACCENT" -m dark </dev/null) || true
[[ -d "$HOME/.themes/$THEME" ]] || { echo "theme build failed"; exit 1; }

# libadwaita / GTK4 apps read ~/.config/gtk-4.0/gtk.css
mkdir -p "$HOME/.config/gtk-4.0"
for f in gtk.css gtk-dark.css assets; do
  ln -sfn "$HOME/.themes/$THEME/gtk-4.0/$f" "$HOME/.config/gtk-4.0/$f"
done

# --- Icons -------------------------------------------------------------------
echo "==> Papirus icons + Catppuccin folders"
mkdir -p "$HOME/.local/share/icons"
curl -fsSL https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh \
  | env DESTDIR="$HOME/.local/share/icons" sh
git clone -q --depth 1 https://github.com/catppuccin/papirus-folders.git "$TMP/folders"
cp -r "$TMP/folders/src/"* "$HOME/.local/share/icons/Papirus/"
curl -fsSL https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders \
  -o "$TMP/papirus-folders"
bash "$TMP/papirus-folders" -C "$FOLDERS" --theme Papirus-Dark

# --- Apply -------------------------------------------------------------------
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
gsettings set org.gnome.desktop.wm.preferences theme "$THEME"
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
# Shell theme (needs the user-theme extension; scripts/extensions.sh installs it)
dconf write /org/gnome/shell/extensions/user-theme/name "'$THEME'"
echo "Catppuccin applied. Shell theme loads after the next login."
