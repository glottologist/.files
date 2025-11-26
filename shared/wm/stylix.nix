{
  username,
  pkgs,
  ...
}: let
  inherit (import ../../homes/${username}/variables.nix) stylixImage;
in {
  stylix = {
    enable = true;
    base16Scheme = {
      # Catppuccin Latte Base16 Color Scheme
      base00 = "eff1f5"; # Base - main background (light)
      base01 = "e6e9ef"; # Mantle - lighter background
      base02 = "dce0e8"; # Crust - selection background
      base03 = "bcc0cc"; # Surface1 - comments, invisibles
      base04 = "acb0be"; # Surface2 - dark foreground
      base05 = "4c4f69"; # Text - default foreground (dark)
      base06 = "5c5f77"; # Subtext1 - light foreground
      base07 = "6c6f85"; # Subtext0 - lightest foreground
      base08 = "d20f39"; # Red - variables, markup
      base09 = "fe640b"; # Peach - integers, constants
      base0A = "df8e1d"; # Yellow - classes, search
      base0B = "40a02b"; # Green - strings, additions
      base0C = "179299"; # Teal - support, regex
      base0D = "1e66f5"; # Blue - functions, methods
      base0E = "8839ef"; # Mauve - keywords, storage
      base0F = "dc8a78"; # Rosewater - deprecated, tags
    };
    polarity = "light";
    opacity.terminal = 1.0;
    targets = {
      waybar.enable = false;
      starship.enable = false;
      rofi.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      ghostty.enable = true;
      foot.enable = false; # If you want to configure foot manually
      kitty.enable = false; # If you want to configure kitty manually
      vim.enable = false; # If you want to configure vim manually
      vscode.enable = false; # If you want to configure vscode manually
      gtk.enable = false;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
