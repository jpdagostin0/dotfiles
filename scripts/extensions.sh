#!/usr/bin/env bash
# Install + enable the GNOME Shell extensions listed in gnome/extensions.txt.
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
SHELL_VER="$(gnome-shell --version | grep -oE '[0-9]+' | head -1)"

enable_uuid() {
  # Append to enabled-extensions without touching existing entries.
  # (On Wayland the running shell won't see new extensions until re-login,
  #  so `gnome-extensions enable` would fail; editing the key works.)
  python3 - "$1" <<'EOF'
import ast, subprocess, sys
u = sys.argv[1]
cur = ast.literal_eval(subprocess.check_output(
    ["gsettings", "get", "org.gnome.shell", "enabled-extensions"], text=True).replace("@as ", ""))
if u not in cur:
    cur.append(u)
    subprocess.check_call(["gsettings", "set", "org.gnome.shell", "enabled-extensions", str(cur)])
EOF
}

while read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  if [[ "$line" == git:* ]]; then
    read -r url uuid <<<"${line#git:}"
    echo "==> $uuid (git)"
    git clone -q --depth 1 "$url" "$TMP/$uuid"
    (cd "$TMP/$uuid" && gnome-extensions pack --force -o "$TMP" . >/dev/null)
    gnome-extensions install --force "$TMP/$uuid.shell-extension.zip"
  else
    uuid="$line"
    echo "==> $uuid"
    dl="$(curl -fsS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$SHELL_VER" \
          | python3 -c 'import json,sys; print(json.load(sys.stdin).get("download_url",""))')"
    if [[ -z "$dl" ]]; then echo "   !! no build for GNOME $SHELL_VER, skipping"; continue; fi
    curl -fsSL "https://extensions.gnome.org$dl" -o "$TMP/$uuid.zip"
    gnome-extensions install --force "$TMP/$uuid.zip"
  fi
  enable_uuid "$uuid"
done < "$DIR/gnome/extensions.txt"

gsettings set org.gnome.shell disable-user-extensions false
echo "Extensions installed. Log out and back in (Wayland) to load them."
