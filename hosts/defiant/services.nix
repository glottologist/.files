# Firefox and Brave are here rather than in the home profile because
# shared/browsers pulls Zen, which follows nixpkgs-unstable for a newer FFmpeg.
# The agent CLIs need a browser only for their OAuth logins.
{ pkgs, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      PubkeyAuthentication = true;
    };
  };

  services.timesyncd.enable = false;
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [ ];
    extraConfig = ''
      pool time.cloudflare.com iburst nts minpoll 4 maxpoll 6
      pool pool.ntp.org iburst minpoll 4 maxpoll 6
      makestep 1 3
    '';
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    brave
    git
    vim
    htop
    tmux
    kdePackages.kate
  ];
}
