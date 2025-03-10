{pkgs, ...}: let
  buildTmuxPlugin = pkgs.tmuxPlugins.mkTmuxPlugin;
in {
  pomodoro = buildTmuxPlugin {
    pluginName = "tmux-pomodoro-plus";
    version = "v0.1.0";
    src = builtins.fetchTarball {
      name = "tmux-pomodoro-plus";
      url = "https://github.com/olimorris/tmux-pomodoro-plus/archive/dd573296a911dd15ad3d3130cbd1323fb67faa1a.tar.gz";
      sha256 = "0px6780wvf5gkvjzn1jrhbpj4xyw010y7yyqckxcfx58731cj1xh";
    };
  };

  tpm = buildTmuxPlugin {
    pluginName = "tpm";
    version = "v0.1.0";
    src = builtins.fetchTarball {
      name = "tpm";
      url = "https://github.com/tmux-plugins/tpm/archive/693e5a2a0f6acfd2666882655d5dfd32e8c6c50b.tar.gz";
      sha256 = "1zxqay7ssqrxpmj1ga7cdkss16cmx3whs7spp0c7wffpa4yjf3bp";
    };
  };

  tmux-cssh = buildTmuxPlugin {
    pluginName = "tmux-cssh";
    version = "v0.1.0";
    src = builtins.fetchTarball {
      name = "tmux-cssh";
      url = "https://github.com/peikk0/tmux-cssh/archive/9461b71adbbe0ad0d7d82f0bebd4d6b0bf6c19c5.tar.gz";
      sha256 = "1rkxqq5nak70kam266sxbvjxvjpfvvda346v2mv7rxi1p4cg8wpk";
    };
  };

  tmuxresurrect = buildTmuxPlugin {
    pluginName = "tmux-resurrect";
    version = "v2.4.0";
    src = builtins.fetchTarball {
      name = "tmux-resurrect-v2.4.0";
      url = "https://github.com/julenpardo/tmux-resurrect/archive/refs/tags/v2.4.0.tar.gz";
      sha256 = "08nmf3d8klyysl9d2kjrdmsvkwfp3lxsgc74cn02x2haqidsd4cq";
    };
  };
}
