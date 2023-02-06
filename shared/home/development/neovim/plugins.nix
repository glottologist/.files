{ buildVimPlugin }:

{
  asyncrun-vim = buildVimPlugin {
    name = "asyncrun-vim";
    src = builtins.fetchTarball {
      name   = "AsyncRun-Vim-v2.7.5";
      url    = "https://github.com/skywind3000/asyncrun.vim/archive/2.7.5.tar.gz";
      sha256 = "02fiqf4rcrxbcgvj02mpd78wkxsrnbi54aciwh9fv5mnz5ka249m";
    };
  };

  ctrlsf-vim = buildVimPlugin {
    name = "ctrlsf-vim";
    src = builtins.fetchTarball {
      name   = "CtrlSF-Vim-v2.1.2";
      url    = "https://github.com/dyng/ctrlsf.vim/archive/v2.1.2.tar.gz";
      sha256 = "1cl0hkddx7i553lld23zmjbjcqpvyvyzh5gsd0rfpwj12xpdqpw7";
    };
  };


   fzf-hoogle = buildVimPlugin {
     name = "fzf-hoogle-vim";
     src = builtins.fetchTarball {
       name   = "fzf-hoogle-vim-v2.3.0";
       url    = "https://github.com/monkoose/fzf-hoogle.vim/archive/v2.3.0.tar.gz";
       sha256 = "00ay9250wdl8ym70dpv4zbs49g40dla6i48bk1zl95lp62kld4hr";
     };
   };

  material-vim = buildVimPlugin {
    name = "material-vim";
    src = builtins.fetchTarball {
      name   = "material-vim-2021-08-23";
      url    = "https://github.com/kaicataldo/material.vim/archive/3b8e2c3.tar.gz";
      sha256 = "1wi1brm1yml4xw0zpc6q5y0ql145v1hw5rbbcsgafagsipiz4av3";
    };
  };

  vim-gtfo = buildVimPlugin {
    name = "vim-gtfo";
    src = builtins.fetchTarball {
      name   = "Vim-Gtfo-v2.0.0";
      url    = "https://github.com/justinmk/vim-gtfo/archive/2.0.0.tar.gz";
      sha256 = "0zq3pjdiahpq53g27rdd5jjfrz8kddqvm1jpsdqamkd1rjvrwr1y";
    };
  };

  vimRipgrep = buildVimPlugin {
    name = "vim-ripgrep";
    src = builtins.fetchTarball {
      name   = "RipGrep-v1.0.2";
      url    = "https://github.com/mattia72/vim-ripgrep/archive/master.tar.gz";
      sha256 = "1by56rflr0bmnjvcvaa9r228zyrmxwfkzkclxvdfscm7l7n7jnmh";
    };
  };

 vim-devicons = buildVimPlugin {
    name = "vim-devicons";
    src = builtins.fetchTarball {
      name   = "vim-devicons";
      url    = "https://github.com/ryanoasis/vim-devicons/archive/refs/tags/v0.11.0.tar.gz";
      sha256 = "00n818s7wy39gkpfwq5l8awg2qpzi4gj5s16hyrlrlyklrpgl48g";
    };
   };

 vimwhichkey = buildVimPlugin {
    name = "vim-which-key";
    src = builtins.fetchTarball {
      name   = "vim-which-key";
      url    = "https://github.com/liuchengxu/vim-which-key/archive/da2934f.tar.gz";
      sha256 = "18n5mqwgkjsf67jg2r24d4w93hadg7fnqyvmqq6dd5bsmqwp9v14";
    };
   };

 nvimwhichkeysetup = buildVimPlugin {
    name = "nvim-whichkey-setup";
    src = builtins.fetchTarball {
      name   = "nvim-whichkey-setup.lua";
      url    = "https://github.com/AckslD/nvim-whichkey-setup.lua/archive/b2df076.tar.gz";
      sha256 = "02bidgicrrx6jwm6hpcq0waqdzif2rws2q1i47zvi5x9i3zyl5cx";
    };
  };

 vimfstar = buildVimPlugin {
    name = "vimfstar";
    src = builtins.fetchTarball {
      name   = "vimfstar";
      url    = "https://github.com/FStarLang/VimFStar/archive/ad1224c.tar.gz";
      sha256 = "149vyraff0l5g050fpw7cplzvhz9qxixbrrzigbbnyl24d9xgwqm";
    };
  };

 vimligo = buildVimPlugin {
    name = "vim-ligo";
    src = builtins.fetchTarball {
      name   = "vim-ligo";
      url    = "https://github.com/der-alter/vim-ligo/archive/99fbcf1.tar.gz";
      sha256 = "155pfn61h2rillq9l1g7m7k3z5msmp2gf5hc40d74z2qxgalj3k6";
    };
  };

 coc-marketplace = buildVimPlugin {
    name = "coc-marketplace";
    src = builtins.fetchTarball {
      name   = "coc-marketplace";
      url    = "https://github.com/fannheyward/coc-marketplace/archive/master.tar.gz";
      sha256 = "0s6b1a2s0ac7j3h3fjfjals1p6wh9gwzcrdk2hqyb5i21ji41yzi";
    };
  };


 #Themes
 nord-vim = buildVimPlugin {
    name = "nord-vim";
    src = builtins.fetchTarball {
      name   = "nord-vim-v0.17.0";
      url    = "https://github.com/arcticicestudio/nord-vim/archive/refs/tags/v0.17.0.tar.gz";
      sha256 = "0zi86iqc6hznf6vnmhyk7rlqwmkl0gxvjsc55ygxkypa1075lqg3";
    };
  };


 flattened = buildVimPlugin {
    name = "flattened";
    src = builtins.fetchTarball {
      name   = "flattened-v0.17.0";
      url    = "https://github.com/romainl/flattened/archive/6701420a2b200225575dbb2482693f979f496631.tar.gz";
      sha256 = "00g3dqyd058gf1mc2v4vi29m0hvgnv980cpy73j4hapghrqy2r4f";
    };
  };

 papercolor-theme = buildVimPlugin {
    name = "papercolor-theme";
    src = builtins.fetchTarball {
      name   = "papercolor-theme-0.5.0";
      url    = "https://github.com/NLKNguyen/papercolor-theme/archive/refs/tags/v1.0.tar.gz";
      sha256 = "19jr05jk1vdlrhxkza9jx0l2wf93k9high1qk7djnq2sbxj6x9xk";
    };
  };
}
