{
  config,
  lib,
  pkgs,
  ...
}: {
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    tailscale = {
      enable = true;
      extraUpFlags = ["--accept-routes"];
    };
    ollama = {
      enable = true;
      host = "127.0.0.1";
      port = 11434;
    };
    fstrim.enable = true;
    chrony.enable = true;
    smartd = {
      enable = true;
      autodetect = true;
    };
  };

  programs.fish.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
