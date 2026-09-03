{pkgs, ...}: let
  buildTmuxPlugin = pkgs.tmuxPlugins.mkTmuxPlugin;
in {
  # mkTmuxPlugin defaults the run-shell entry point to `<pluginName>.tmux`
  # with hyphens turned into underscores. Upstream's entry point is the bare
  # `tpm` script, so without this tmux was sourcing a tpm.tmux that has never
  # existed and the plugin silently never loaded.
  tpm = buildTmuxPlugin {
    pluginName = "tpm";
    rtpFilePath = "tpm";
    version = "v3.1.0";
    src = builtins.fetchTarball {
      name = "tpm";
      url = "https://github.com/tmux-plugins/tpm/archive/refs/tags/v3.1.0.tar.gz";
      sha256 = "18i499hhxly1r2bnqp9wssh0p1v391cxf10aydxaa7mdmrd3vqh9";
    };
  };


  # Same defaulting as tpm above: the derived `tmux_menus.tmux` is not a file
  # upstream ships. The entry point is `menus.tmux`.
  tmux-menus = buildTmuxPlugin {
    pluginName = "tmux-menus";
    rtpFilePath = "menus.tmux";
    version = "v2.2.18";
    src = builtins.fetchTarball {
      name = "tmux-menus-v2.2.18";
      url = "https://github.com/jaclu/tmux-menus/archive/refs/tags/v2.2.18.tar.gz";
      sha256 = "1bf44h55zvdpzl4cl7c2qf7crvfn2mdhphg6j0rcjcv8hpdqd6y8";
    };
  };

  # Both names have to read "resurrect". default.nix merges this set over
  # pkgs.tmuxPlugins, so the attribute name is what displaces the nixpkgs
  # plugin, and mkTmuxPlugin derives the run-shell entry point from
  # pluginName: "tmux-resurrect" pointed tmux at a tmux_resurrect.tmux that
  # the upstream tree does not carry.
  resurrect = buildTmuxPlugin {
    pluginName = "resurrect";
    version = "v4.0.0";
    src = builtins.fetchTarball {
      name = "tmux-resurrect";
      url = "https://github.com/tmux-plugins/tmux-resurrect/archive/refs/tags/v4.0.0.tar.gz";
      sha256 = "1a7h835kzwz21amha0dp25hyhgisrfi053hrl06cnznd6vns90z3";
    };
    # The release tarball carries the test harness as symlinks into
    # lib/tmux-test, a submodule the archive itself leaves out, and the
    # noBrokenSymlinks fixup fails the build on them. Nothing at runtime
    # reads them.
    postInstall = ''
      find $target -xtype l -delete
    '';
  };
}
