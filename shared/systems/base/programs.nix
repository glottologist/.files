{
  config,
  pkgs,
  ...
}: {
  programs = {
  seahorse.enable = true;
  dconf.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
