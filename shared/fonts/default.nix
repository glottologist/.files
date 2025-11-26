{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./emoji.nix
  ];
  home.file = {
    "Pictures/Emojis" = {
      source = ./emojis;
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];
}
