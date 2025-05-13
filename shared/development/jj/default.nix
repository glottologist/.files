{
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
      ui = {
        pager = "less -FRX";
        show-cryptographic-signatures = true;
      };
      signing = let
        gitCfg = config.programs.git.extraConfig;
      in {
        backend = "gpg";
        behaviour =
          if gitCfg.commit.gpgSign
          then "own"
          else "never";
        key = config.programs.git.signing.key;
      };
    };
  };
}
