{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: let
  inherit (pkgs) vscode-utils vscode-extensions;
  native-ext = with vscode-extensions; [
    arcticicestudio.nord-visual-studio-code
    # asvetliakov.vscode-neovim
    b4dm4n.vscode-nixpkgs-fmt
    bbenoist.nix
    brandonkirbyson.solarized-palenight
    catppuccin.catppuccin-vsc-icons
    esbenp.prettier-vscode
    formulahendry.code-runner
    foxundermoon.shell-format
    fstarlang.fstar-vscode-assistant
    github.vscode-github-actions
    github.vscode-pull-request-github
    gitlab.gitlab-workflow
    golang.go
    gruntfuggly.todo-tree
    haskell.haskell
    ibm.output-colorizer
    ionide.ionide-fsharp
    justusadam.language-haskell
    kamikillerto.vscode-colorize
    maximedenes.vscoq
    mkhl.direnv
    ms-python.black-formatter
    ms-python.python
    ms-toolsai.jupyter
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vsliveshare.vsliveshare
    ocamllabs.ocaml-platform
    pkief.material-icon-theme
    redhat.vscode-yaml
    rust-lang.rust-analyzer
    scala-lang.scala
    scalameta.metals
    vscodevim.vim
    vue.vscode-typescript-vue-plugin
    zhuangtongfa.material-theme
  ];

  built-ext = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix).extensions;

  ext = native-ext ++ built-ext;

  settings = (import ./settings.nix).user;

  code = pkgs.vscode;

  overridePackage =
    (pkgs.vscode-with-extensions.override {
      vscode = code;
      vscodeExtensions = ext;
    }).overrideAttrs (old: {
      inherit (code) pname version;
    });
in {
  programs.vscode = {
    enable = true;
    package = overridePackage;
    profiles.default.userSettings = settings;
  };

  imports = [
    "${builtins.fetchTarball {
      url = "https://github.com/nix-community/nixos-vscode-server/archive/92ce71c3ba5a94f854e02d57b14af4997ab54ef0.tar.gz";
      sha256 = "0xjal4zcbmdjdaspfkjbpx1680q7390wfzmj7iad04kp3pc9syf8";
    }}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;
}
