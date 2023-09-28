{
  config,
  pkgs,
  ...
}: {
  services = {

    sshd.enable = true;

    xrdp = {
      enable = true;
      defaultWindowManager = "${pkgs.icewm}/bin/icewm";
    };

    vnstat.enable = true;

    openssh = {
      enable = true;
      allowSFTP = true;
    };

    syncthing = {
      enable = true;
      all_proxy = null;
      dataDir = "/home/jason/.syncthing";
      user = "jason";
    };

    netdata = {
      enable = true;
      config = {
        global = {
          "default port" = "19999";
          "bind to" = "*";
          # 7 days
          "history" = "604800";
          "error log" = "syslog";
          "debug log" = "syslog";
        };
      };
    };
  };

  systemd.services.upower.enable = true;
}
