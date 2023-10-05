{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    brave # Privacy-oriented browser for Desktop and Laptop computers
    firefox # A web browser built from Firefox source tree
    qutebrowser # Keyboard-focused browser with a minimal GUI.
    tor-browser-bundle-bin # Tor Browser Bundle built by torproject.org
    nyxt # Infinitely extensible web-browser (with Lisp development files using WebKitGTK platform port)
    chromium # An open source web browser from Google
    google-chrome #  A freeware web browser developed by Google
  ];

  xdg.configFile."qutebrowser/config.py".text = builtins.readFile ../../../secrets/qb_config.py;
  xdg.configFile."qutebrowser/catppuccin/.editorconfig".text = builtins.readFile ./qutebrowser/catppuccin/editorconfig;
  xdg.configFile."qutebrowser/catppuccin/__init__.py".text = builtins.readFile ./qutebrowser/catppuccin/__init__.py;
  xdg.configFile."qutebrowser/catppuccin/setup.py".text = builtins.readFile ./qutebrowser/catppuccin/setup.py;
}
