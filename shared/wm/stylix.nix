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
      base00 = "282936";
      base01 = "3a3c4e";
      base02 = "4d4f68";
      base03 = "626483";
      base04 = "62d6e8";
      base05 = "e9e9f4";
      base06 = "f1f2f8";
      base07 = "f7f7fb";
      base08 = "ea51b2";
      base09 = "b45bcf";
      base0A = "00f769";
      base0B = "ebff87";
      base0C = "a1efe4";
      base0D = "62d6e8";
      base0E = "b45bcf";
      base0F = "00f769";
    };
    polarity = "light";
    opacity.terminal = 1.0;
    targets = {
      waybar.enable = false;
      starship.enable = false;
      rofi.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      ghostty.enable = false;
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
