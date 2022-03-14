{ pkgs, ... }:

let
  buildTmuxPlugin = pkgs.tmuxPlugins.mkTmuxPlugin;
in
  {

  pomodoro = buildTmuxPlugin {
    pluginName = "tmux-pomodoro-plus";
    version = "v0.1.0";
    src = builtins.fetchTarball {
      name   = "tmux-pomodoro-plus";
      url    = "https://github.com/olimorris/tmux-pomodoro-plus/archive/dd573296a911dd15ad3d3130cbd1323fb67faa1a.tar.gz";
      sha256 = "0px6780wvf5gkvjzn1jrhbpj4xyw010y7yyqckxcfx58731cj1xh";
    };
  };

  tpm = buildTmuxPlugin {
    pluginName = "tpm";
    version = "v0.1.0";
    src = builtins.fetchTarball {
      name   = "tpm";
      url    = "https://github.com/tmux-plugins/tpm/archive/693e5a2a0f6acfd2666882655d5dfd32e8c6c50b.tar.gz";
      sha256 = "1zxqay7ssqrxpmj1ga7cdkss16cmx3whs7spp0c7wffpa4yjf3bp";
    };
  };

  tmux-cssh = buildTmuxPlugin {
    pluginName = "tmux-cssh";
    version = "v0.1.0";
    src = builtins.fetchTarball {
      name   = "tmux-cssh";
      url    = "https://github.com/peikk0/tmux-cssh/archive/9461b71adbbe0ad0d7d82f0bebd4d6b0bf6c19c5.tar.gz";
      sha256 = "1rkxqq5nak70kam266sxbvjxvjpfvvda346v2mv7rxi1p4cg8wpk";
    };
  };

  tsol = buildTmuxPlugin {
    pluginName = "tmux-colors-solarized";
    version = "v0.1.0";
    src = builtins.fetchTarball {
      name   = "tmux-colors-solarized";
      url    = "https://github.com/seebi/tmux-colors-solarized/archive/e5e7b4f1af37f8f3fc81ca17eadee5ae5d82cd09.tar.gz";
      sha256 = "1l3i82abzi4b395cgdsjg7lcfaq15kyyhijwvrgchzxi95z3hl4x";
    };
  };

  nord = buildTmuxPlugin {
    pluginName = "nord";
    version = "v0.3.0";
    src = builtins.fetchTarball {
      name   = "Nord-Tmux-2020-08-25";
      url    = "https://github.com/glottologist/nord-tmux/refs/tags/v0.3.0.tar.gz";
      sha256 = "0l97cqbnq31f769jak31ffb7bkf8rrg72w3vd0g3fjpq0717864a";
    };
  };


  tmuxresurrect = buildTmuxPlugin {
    pluginName = "tmux-resurrect";
    version = "v2.4.0";
    src = builtins.fetchTarball {
      name   = "tmux-resurrect-v2.4.0";
      url    = "https://github.com/julenpardo/tmux-resurrect/archive/refs/tags/v2.4.0.tar.gz";
      sha256 = "08nmf3d8klyysl9d2kjrdmsvkwfp3lxsgc74cn02x2haqidsd4cq";
    };
  };

  gruvbox-light = buildTmuxPlugin {
    pluginName = "gruvbox-light-tmux";
    version = "v2.4.0";
    src = builtins.fetchTarball {
      name   = "gruvbox-light-tmux-v0.3.0";
      url    = "https://github.com/gvdenbro/gruvbox-light-tmux/archive/refs/tags/v0.3.0.tar.gz";
      sha256 = "14xhh49izvjw4ycwq5gx4if7a0bcnvgsf3irywc3qps6jjcf5ymk";
    };
  };

  gruvbox = buildTmuxPlugin {
    pluginName = "tmux-gruvbox";
    version = "v1.0.0";
    src = builtins.fetchTarball {
      name   = "tmux-gruvbox-v1.0.0";
      url    = "https://github.com/egel/tmux-gruvbox/archive/refs/tags/v1.0.0.tar.gz";
      sha256 = "0vsyf0x96shhg111gvn770dkblmaqwkz57prwkab67722zy0dn53";
    };
  };
  iceberg = buildTmuxPlugin {
    pluginName = "tmux-iceberg";
    version = "v1.0.0";
    src = builtins.fetchTarball {
      name   = "tmux-gruvbox-v1.0.0";
      url    = "https://github.com/lamartire/iceberg.tmux/archive/755b6f7fa9bb47c7d266f4852a52f1a0b6850b3b.tar.gz";
      sha256 = "0vsyf0x96shhg111gvn770dkblmaqwkz57prwkab67722zy0dn53";
    };
  };
}
