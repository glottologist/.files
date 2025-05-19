{
  config,
  pkgs,
  lib,
  ...
}: let
  fzfConfig = ''
    set -x SKIM_DEFAULT_COMMAND "rg --files || fd || find ."
  '';

  gpgConfig = ''
    export GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    gpgconf --launch gpg-agent
  '';

  themeConfig = ''
    set -g theme_display_date no
    set -g theme_nerd_fonts yes
    set -g theme_newline_cursor yes
    set -g theme_color_scheme catppuccin_latte
  '';

  fishConfig =
    ''
      bind \t accept-autosuggestion
      set fish_greeting
      fish_vi_key_bindings
      shellclear --init-shell
    ''
    + gpgConfig
    + fzfConfig
    + themeConfig;

  custom = pkgs.callPackage ./plugins.nix {};
in {
  home.packages = with pkgs; [
    figlet # Terminal ASCII pictures
  ];
  imports = [
    ./functions.nix
    ./themes.nix
  ];
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "bass";
        src = pkgs.fishPlugins.bass.src;
      }
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      {
        name = "pisces";
        src = pkgs.fishPlugins.pisces.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "59228d6215cb4c36aff77008751736f540dc42d8";
          sha256 = "0581z6mzi6wjfqm4hcbl9w2haq3zfa5p1jgql5y7q2jwsn1lyzvr";
        };
      }
    ];
    interactiveShellInit = ''
      if test -e ~/.nix-profile/etc/profile.d/hm-session-vars.sh
         bass source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      end
      any-nix-shell fish --info-right | source
    '';
    shellAliases = {
      ".-" = "cd - ";
      ".." = "cd ..";
      alarm = "termdown --blink --text 'FINISHED'";
      boox = "cd ~/Ontologi Dropbox/Jason Ridgway-Taylor/DOCUMENTS/Personal/Boox/";
      bt = "bluetoothctl";
      cb = "clear && cargo build";
      cc = "cargo clean";
      cck = "cargo check";
      clip = "clear && cargo clippy";
      cdoc = "cargo doc";
      cf = "cargo fmt --all";
      cbh = "cargo bench";
      clb = "cabal build";
      clr = "clear";
      clrn = "cabal run";
      clrp = "cabal repl";
      clt = "cabal test";
      cn = "cargo new";
      coin = "cointop";
      cprf = "cp -rf";
      cr = "cargo run";
      crg = "crate2nix generate";
      ct = "cargo test";
      cu = "cargo update";
      cw = "cargo watch -s 'clear; cargo check --tests --color=always 2>&1 | head -40'";
      db = "docker build -t";
      dc = "docker-compose";
      dcd = "docker-compose down --remove-orphans";
      dcps = "docker-compose ps";
      dcu = "docker-compose up";
      de = "devenv shell";
      dec = "devenv ci";
      dei = "devenv init";
      des = "devenv search";
      deu = "devenv update";
      dev = "cd ~/development";
      di = "docker images";
      disk = "diskonaut /";
      dka = "docker kill (docker ps | awk '{print $1}' | grep -v CONTAINER)";
      doc = "cd ~/Documents";
      dock = "lazydocker";
      dotb = "dotnet build";
      dotbat = "dotnet build && dotnet test";
      dotc = "dotnet clean";
      dott = "dotnet test";
      down = "cd ~/Downloads";
      dps = "docker ps";
      dpsa = "docker ps -a";
      dr = "docker run ";
      dri = "docker run -it --rm";
      drmi = "docker rmi --force (docker images | awk '{print $3}')";
      drop = "cd ~/Dropbox";
      du = "ncdu --color dark -rr -x";
      dut = "dune exec ./main.exe -- test";
      dva = "devbox add";
      dvat = "devbox auth";
      dvc = "devbox cache";
      dvco = "devbox completion";
      dvcr = "devbox create";
      dvgen = "devbox generate";
      dvgl = "devbox global";
      dvinf = "devbox info";
      dvini = "devbox init";
      dvins = "devbox install";
      dvls = "devbox list";
      dvrm = "devbox rm";
      dvru = "devbox run";
      dvse = "devbox search";
      dvsec = "devbox secrets";
      dvser = "devbox services";
      dvsh = "devbox shell";
      dvshenv = "devbox shellenv";
      dvu = "devbox update";
      e = "exit";
      eo = "eval (opam env)";
      eop = "eval (opam env)";
      exe = "cd ~/development/exercism";
      files = "cd ~/development/glottologist/.files";
      fs = "flameshot gui";
      ga = "git add";
      gaa = "git add -A";
      gac = "git add -A && git commit -am";
      gb = "git branch";
      gbr = "git branch -r";
      gc = "git commit -m ";
      gca = "git commit -a ";
      gcam = "git commit -am ";
      gcf = "git clean -f";
      gcl = "git clone ";
      gclb = "git clone --bare ";
      gclgh = "git clone git@github.com:";
      gcn = "git clean -n";
      gco = "git checkout ";
      gd = "git diff ";
      gi = "git ignore";
      gia = "git ignore -a";
      gii = "git ignore init";
      gil = "git ignore -l";
      giu = "git ignore -u";
      gl = "git l19";
      gla = "git la19";
      glga = "git lga";
      glo = "git log --oneline";
      glot = "cd ~/development/glottologist";
      gls = "git ls-files";
      gone = "git log --oneline";
      gp = "git pull";
      gpa = "git push && git push --tags";
      gpgtty = "export GPG_TTY=$(tty)";
      gps = "git push";
      gpt = "git push --tags";
      grbi = "git rebase -i";
      grbm = "git rebase main";
      grbms = "git rebase master";
      grh = "git reset --hard HEAD~1";
      grm = "git reset --merge";
      grs = "git reset --soft HEAD~1";
      gs = "git status";
      gsp = "git stash pop";
      gss = "git stash save";
      gts = "cd $HOME/.config/tmux git pull && cd -";
      gus = "git submodule update --init --recursive";
      gwa = "git worktree add";
      gwl = "git worktree list";
      gwlk = "git worktree lock";
      gwm = "git worktree move";
      gwp = "git worktree prune";
      gwr = "git worktree remove";
      gwrp = "git worktree repair";
      gwu = "git worktree unlock";
      h = "history";
      hg = "history | grep";
      hm = "home-manager";
      hmrg = "home-manager expire-generations 'now'";
      hy = "history";
      jjdg = "jj diff --git";
      jjr = "jj rebase";
      jjb = "jj bookmark";
      jje = "jj evolog";
      jjfu = "jj file untrack";
      jjgc = "jj git clone";
      jjgf = "jj git clone";
      jjgp = "jj git push";
      jjfo = "jj git fetch --remote origin";
      jjgpb = "jj git push --bookmark";
      jjbla = "jj bookmark list --all";
      jjgic = "jj git init --colocate";
      jjl = "jj log";
      jjn = "jj new";
      jjnm = "jj new -m";
      jjs = "jj squash";
      jjst = "jj status";
      k = "kubectl ";
      kaf = "kubectl apply -f";
      kcp = "kubectl cp ";
      kdn = "kubectl describe node ";
      kdp = "kubectl delete pod ";
      kge = "kubectl get events --sort-by='\'{.lastTimestamp}'\' ";
      kgn = "kubectl get nodes";
      kgp = "kubectl get pod ";
      kl = "kubectl logs ";
      kn = "kubens ";
      know = "cd ~/Documents/knowledge";
      kpf = "kubectl port-forward ";
      kx = "kubectx ";
      la = "lsd -la";
      lag = "lsd -la | grep";
      lang = "cd ~/Documents/languages";
      lar = "lsd -laR";
      larg = "lsd -laR | grep";
      lass = "lsd -la --tree --sizesort";
      lassg = "lsd -la --tree --sizesort | grep";
      last = "lsd -la --tree --timesort";
      lastg = "lsd -la --tree --timesort | grep";
      lat = "lsd -la --tree";
      latg = "lsd -la --tree | grep";
      lats = "lsd --tree --sizesort";
      latsg = "lsd --tree --sizesort | grep";
      latt = "lsd --tree --timesort";
      lattg = "lsd --tree --timesort | grep";
      lock = "sudo cryptsetup luksClose";
      lrt = "ligo run test";
      ls = "lsd";
      lsg = "lsd | grep";
      lsr = "lsd -R";
      lsrg = "lsd -R | grep";
      lst = "lsdu --tree";
      lstg = "lsdu --tree | grep";
      me = "cd ~/development/glottologist/me";
      mkk = "minikube kubectl";
      mksc = "minikube config set cpus 4";
      mksm = "minikube config set memory 6144";
      mksp = "minikube stop";
      mkst = "minikube start";
      nb = "nix build";
      ncg = "nix-collect-garbage -d";
      nconf = "cd ~/development/glottologist/nix-config";
      nd = "nix develop";
      ndi = "nix develop --impure";
      ne = "nix-env";
      news = "newsboat";
      nill = "cd ~/development/nillion";
      notes = "cd ~/Documents/notes";
      npks = "cd ~/development/glottologist/nixpkgs";
      nr = "nix run";
      ns = "nix-env -q -a --attr-path ";
      nsf = "nix search";
      ont = "cd ~/development/ontologi";
      oss = "cd ~/development/opensource";
      pb = "docker build -t";
      pc = "docker-compose";
      pcd = "docker-compose down --remove-orphans";
      pcps = "docker-compose ps";
      pcu = "docker-compose up";
      pi = "podman images";
      pka = "podman kill (podman ps | awk '{print $1}' | grep -v CONTAINER)";
      pps = "podman ps";
      ppsa = "podman ps -a";
      pr = "podman run ";
      pri = "podman run -it --rm";
      prmi = "podman rmi --force (podman images | awk '{print $3}')";
      pres = "cd ~/Documents/presentations";
      pullall = "find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;";
      recr = "cd ~/development/glottologist/recruitment";
      ref = "cd ~/development/reference";
      rf = "rofi -show drun -show-icons";
      rmcaps = "xmodmap -e 'remove lock = Caps_Lock' && xmodmap -e 'keysym Caps_Lock = Control space'";
      scr = "cd ~/development/scratch";
      setmtu = "sudo ip link set dev eth0 mtu 1350";
      space = "sudo ncdu -x /";
      sshkc = "ssh-copy-id -i ~/.ssh/id_ed25519";
      st = "speedtest";
      sts = "cd $HOME/.config/tmux && git add -A && git commit -am 'Sync sessions' && git push && cd -";
      syncall = "syncme && syncknow && synclang && syncnotes";
      syncknow = "cd ~/Documents/knowledge && git add -A && git commit -am 'Sync knowledge' && git push && cd - ";
      syncme = "cd ~/development/glottologist/me && git add -A && git commit -am 'Update content' && git push && cd - ";
      synclang = "cd ~/Documents/languages && git add -A && git commit -am 'Sync languages' && git push && cd - ";
      syncmail = "mbsync -V --all";
      syncnoah = "cd ~/Documents/noah && git add -A && git commit -am 'Sync noah' && git push && cd - ";
      syncnotes = "cd ~/Documents/notes && git add -A && git commit -am 'Sync notes' && git push && cd - ";
      t = "export TERM=foot && tmux ";
      ta = "export TERM=foot && tmux attach ";
      tas = "export TERM=foot && tmux attach -t ";
      testnix = "export NIXPKGS=/home/jason/development/glottologist/nixpkgs && nix-env -f $NIXPKGS -iA";
      tf = "terraform ";
      tk = "cd ~/Documents/tasks && dstask";
      tks = "export TERM=foot && tmux kill-session -t ";
      tls = "export TERM=foot && tmux ls ";
      tns = "export TERM=foot && tmux new-session -s ";
      tree = "exa -T";
      tsk = "cd ~/Documents/tasks && dstask sync && dstask";
      tuk = "cd ~/development/tuktoken";
      unlock = "sudo cryptsetup luksOpen";
      v = "nix run ~/development/glottologist/nvim-flake#developer";
      vd = "vimdiff";
      vn = "nix run ~/development/glottologist/nvim-flake";
      vnd = "nix run ~/development/glottologist/nvim-flake#developer";
      vndr = "nix run ~/development/glottologist/nvim-flake#developer -w ~/.vimlog";
      vg = "nix run github:glottologist/nvim-flake";
      vgd = "nix run github:glottologist/nvim-flake#developer";
      vnl = "nix run -I ~/development/glottologist/nvim-flake";
      vpn = "nordvpn";
      vpnc = "nordvpn connect";
      vpnd = "nordvpn disconnect";
      vpnh = "nordvpn --help";
      wat = "watchexec";
      wipe = "lethe wipe -s dod";
      wipedeep = "lethe wipe -s vsitr";
      wipehelp = "lethe wipe --help";
      wipewith = "lethe wipe -s";
      wipezero = "lethe wipe -s zero";
      wp = "export QT_QPA_PLATFORM=xcb; whatpulse";
    };
    shellInit = fishConfig;
  };

  xdg.configFile."fish/completions/keytool.fish".text = custom.completions.keytool;
}
