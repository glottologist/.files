{pkgs, ...}: let
  buildTmuxPlugin = pkgs.tmuxPlugins.mkTmuxPlugin;
in {
  pomodoro = buildTmuxPlugin {
    pluginName = "tmux-pomodoro-plus";
    version = "v1.0.2";
    src = builtins.fetchTarball {
      name = "tmux-pomodoro-plus";
      url = "https://github.com/olimorris/tmux-pomodoro-plus/archive/refs/tags/v1.0.2.tar.gz";
      sha256 = "0px6780wvf5gkvjzn1jrhbpj4xyw010y7yyqckxcfx58731cj1xh";
    };
  };

  tpm = buildTmuxPlugin {
    pluginName = "tpm";
    version = "v3.1.0";
    src = builtins.fetchTarball {
      name = "tpm";
      url = "https://github.com/tmux-plugins/tpm/archive/refs/tags/v3.1.0.tar.gz";
      sha256 = "18i499hhxly1r2bnqp9wssh0p1v391cxf10aydxaa7mdmrd3vqh9";
    };
  };


  tmux-menus = buildTmuxPlugin {
    pluginName = "tmux-menus";
    version = "v2.2.18";
    src = builtins.fetchTarball {
      name = "tmux-menus-v2.2.18";
      url = "https://github.com/jaclu/tmux-menus/archive/refs/tags/v2.2.18.tar.gz";
      sha256 = "1bf44h55zvdpzl4cl7c2qf7crvfn2mdhphg6j0rcjcv8hpdqd6y8";
    };
  };

  tmuxresurrect = buildTmuxPlugin {
    pluginName = "tmux-resurrect";
    version = "v4.0.0";
    src = builtins.fetchTarball {
      name = "tmux-resurrect";
      url = "https://github.com/tmux-plugins/tmux-resurrect/archive/refs/tags/v4.0.0.tar.gz";
      sha256 = "1a7h835kzwz21amha0dp25hyhgisrfi053hrl06cnznd6vns90z3";
    };
  };
}
