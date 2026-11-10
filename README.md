dotfiles
========

GNOME (Wayland, dwm-style Alt keybinds) + Catppuccin Mocha + Ghostty.

What's here
-----------
  ghostty/config.ghostty     Ghostty: Catppuccin Mocha, Monaspice Nerd Font, st-like no chrome
  gtk/                       GTK3/4 settings.ini (prefer dark)
  gnome/extensions.txt       Shell extensions to install (extensions.gnome.org + git)
  gnome/dconf/*.ini          dconf dumps: extension settings, Alt keybinds, workspaces,
                             media-keys (Alt+Shift+Return -> ghostty), interface/theme
  scripts/catppuccin.sh      Builds Catppuccin GTK/Shell theme (Mauve, dark) into ~/.themes,
                             links GTK4/libadwaita CSS, installs Papirus-Dark icons with
                             Catppuccin Mocha Mauve folders
  scripts/extensions.sh      Downloads + enables the extensions for your GNOME version
  scripts/dump-gnome.sh      Re-export current GNOME settings back into gnome/dconf/

Install
-------
  git clone https://github.com/jpdagostin0/dotfiles ~/dotfiles
  cd ~/dotfiles && ./install.sh            # everything
  ./install.sh links|catppuccin|extensions|gnome   # individual steps

Then log out and back in (Wayland can't reload the shell in place).

Notes
-----
- No root needed. If sassc isn't installed and sudo isn't available, the theme build
  uses libsass' pysassc through a small shim.
- Different accent: ACCENT=blue FOLDERS=cat-mocha-blue ./install.sh catppuccin
- Existing config files are moved to *.bak-<timestamp> before being symlinked.
- Not managed: the redglass cursor theme and the MonaspiceNe Nerd Font (install separately).

Credits
-------
Theme: Fausto-Korpsvart/Catppuccin-GTK-Theme
Icons: PapirusDevelopmentTeam/papirus-icon-theme + catppuccin/papirus-folders
