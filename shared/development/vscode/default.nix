{ config, lib, pkgs, stdenv, ... }:
let
  inherit (pkgs) vscode-utils vscode-extensions;
  native-ext = with vscode-extensions;
      [
        #ms-python.python
        freebroccolo.reasonml
        github.vscode-pull-request-github
        haskell.haskell
        ibm.output-colorizer
        justusadam.language-haskell
        ms-azuretools.vscode-docker
        ms-dotnettools.csharp
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-vsliveshare.vsliveshare
        ocamllabs.ocaml-platform
        pkief.material-icon-theme
        redhat.vscode-yaml
        scala-lang.scala
        scalameta.metals
        vscodevim.vim
        zhuangtongfa.material-theme
        github.copilot
      ];

  built-ext = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix).extensions;

  ext = (native-ext) ++ built-ext;

  settings = (import ./settings.nix).user;

  code = pkgs.vscode;

  overridePackage = (pkgs.vscode-with-extensions.override {
    vscode = code;
    vscodeExtensions = ext;
  }).overrideAttrs (old: {
    inherit (code) pname version;
  });
in
{
  programs.vscode = {
    enable = true;
    package = overridePackage;
    profiles.default.userSettings = settings;
  };

  imports = [
    #"${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  #services.vscode-server.enable = true;

}
