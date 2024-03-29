{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
   # brave # Privacy-oriented browser for Desktop and Laptop computers
    qutebrowser # Keyboard-focused browser with a minimal GUI.
    tor-browser-bundle-bin # Tor Browser Bundle built by torproject.org
  ];

  xdg.configFile."qutebrowser/config.py".text = builtins.readFile ../../secrets/qb_config.py;
  xdg.configFile."qutebrowser/catppuccin/.editorconfig".text = builtins.readFile ./qutebrowser/catppuccin/editorconfig;
  xdg.configFile."qutebrowser/catppuccin/__init__.py".text = builtins.readFile ./qutebrowser/catppuccin/__init__.py;
  xdg.configFile."qutebrowser/catppuccin/setup.py".text = builtins.readFile ./qutebrowser/catppuccin/setup.py;
  xdg.dataFile."qutebrowser/userscripts/qute-1pass".text = builtins.readFile ./qutebrowser/qute-1pass;
}
