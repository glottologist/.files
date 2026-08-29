{
  pkgs,
  username,
  ...
}: {
  home.packages = [
    (import ./emopicker9000.nix {inherit pkgs;})
    (import ./keybinds.nix {inherit pkgs;})
    (import ./task-waybar.nix {inherit pkgs;})
    (import ./squirtle.nix {inherit pkgs;})
    (import ./nvidia-offload.nix {inherit pkgs;})
    (import ./wallsetter.nix {
      inherit pkgs;
      inherit username;
    })
    (import ./web-search.nix {inherit pkgs;})
    (import ./rofi-launcher.nix {inherit pkgs;})
    (import ./screenshootin.nix {inherit pkgs;})
    (import ./unified-clipboard.nix {inherit pkgs;})
    (import ./ocr-clip.nix {inherit pkgs;})
    (import ./reminder.nix {inherit pkgs;})
    (import ./omarchy-menu.nix {inherit pkgs;})
    (import ./default-agent.nix {inherit pkgs;})
  ];
}
