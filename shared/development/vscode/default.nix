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
    asvetliakov.vscode-neovim
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

  # 1.144 ships rg at @vscode/ripgrep-universal/bin/linux-<arch>/rg (unpacked).
  # nixpkgs still `rm`s @vscode/ripgrep/bin/rg, which is no longer in the
  # tarball, so patchPhase fails. Keep the nixpkgs ripgrep swap, at the
  # path the resolver actually uses, and at the legacy path extensions look up.
  code = pkgs.vscode.overrideAttrs (old: let
    rgArch =
      if pkgs.stdenv.hostPlatform.isx86_64 then
        "x64"
      else if pkgs.stdenv.hostPlatform.isAarch64 then
        "arm64"
      else
        throw "vscode ripgrep override does not know ${pkgs.stdenv.hostPlatform.system}";
    legacy = "resources/app/node_modules/@vscode/ripgrep/bin/rg";
    universalDir = "resources/app/node_modules/@vscode/ripgrep-universal/bin/linux-${rgArch}";
    unpacked = "resources/app/node_modules.asar.unpacked/@vscode/ripgrep-universal/bin/linux-${rgArch}/rg";
    from = ''
      rm ${legacy}
      ln -s ${pkgs.ripgrep}/bin/rg ${legacy}'';
    to = ''
      mkdir -p ${universalDir} "$(dirname ${legacy})" "$(dirname ${unpacked})"
      ln -sfn ${pkgs.ripgrep}/bin/rg ${universalDir}/rg
      ln -sfn ${pkgs.ripgrep}/bin/rg ${legacy}
      ln -sfn ${pkgs.ripgrep}/bin/rg ${unpacked}'';
    patched = builtins.replaceStrings [ from ] [ to ] old.postPatch;
  in {
    postPatch =
      if patched == old.postPatch then
        throw "vscode postPatch no longer removes ${legacy}; drop the override in shared/development/vscode/default.nix"
      else
        patched;
  });

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
