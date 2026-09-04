{...}: {
  # Both profiles are installed; the login screen picks the session.
  imports = [
    ./stylix.nix
    ./classic/default.nix
    ./caelestia/default.nix
    ./omnixy/default.nix
  ];
}
