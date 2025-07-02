{
  config,
  pkgs,
  ...
}: {
  programs = {
    # steam = {
    #   enable = true;
    #   remotePlay.openFirewall = true;
    #   gamescopeSession.enable = true;
    #   dedicatedServer.openFirewall = false;
    #   extraCompatPackages = [pkgs.proton-ge-bin];
    # };
    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
  };
  environment.systemPackages = with pkgs; [
  ];
}
