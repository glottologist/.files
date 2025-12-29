{
  config,
  pkgs,
  ...
}: {
  programs = {
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
