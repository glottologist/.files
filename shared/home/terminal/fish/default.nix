{
  config,
  pkgs,
  lib,
  ...
}: let
  fzfConfig = ''
    set -x FZF_DEFAULT_OPTS "--preview='bat {} --color=always'" \n
    set -x SKIM_DEFAULT_COMMAND "rg --files || fd || find ."
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
    ''
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
        eval (direnv hook fish)
      any-nix-shell fish --info-right | source
    '';
    shellAliases = {
      ".-" = "cd - ";
      ".." = "cd ..";
      alarm = "termdown --blink --text 'FINISHED'";
      art = "cd ~/Documents/articles";
      boox = "cd ~/Ontologi Dropbox/Jason Ridgway-Taylor/DOCUMENTS/Personal/Boox/";
      bt = "bluetoothctl";
      cat = "bat";
      cb = "cargo build";
      cbn = "cargo bench";
      cc = "cargo clean";
      cck = "cargo check";
      cdoc = "cargo doc";
      cf = "cargo fmt --all";
      clb = "cabal build";
      clr = "clear";
      clrn = "cabal run";
      clrp = "cabal repl";
      clt = "cabal test";
      cn = "cargo new";
      coin = "cointop";
      cone = "cd ~/development/chorusone";
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
      disk = "sudo diskonaut /";
      dka = "docker kill (docker ps | awk '{print $1}' | grep -v CONTAINER)";
      doc = "cd ~/Documents";
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
      eo = "eval (opam env)";
      eop = "eval (opam env)";
      exe = "cd ~/development/exercism";
      files = "cd ~/development/glottologist/.files";
      flash = "cd ~/Documents/flashcards";
      fs = "flameshot gui";
      ftc = "docker exec flex tezos-client";
      ga = "git add";
      gaa = "git add -A";
      gac = "git add -A && git commit -am";
      gb = "git branch";
      gbr = "git branch -r";
      gc = "git commit -am ";
      gcf = "git clean -f";
      gcl = "git clone ";
      gclb = "git clone --bare ";
      gclgh = "git clone git@github.com:";
      gcn = "git clean -n";
      gco = "git checkout ";
      gd = "git diff ";
      gl = "git l19";
      gla = "git la19";
      glga = "git lga";
      glo = "git log --oneline";
      glot = "cd ~/development/glottologist";
      gls = "git ls-files";
      gone = "git log --oneline";
      gp = "git pull";
      gpa = "git push && git push --tags";
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
      int = "cd ~/development/intenda";
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
      lcc = "ligo compile contract";
      lce = "ligo compile expression";
      lcp = "ligo compile parameter";
      lcs = "ligo compile storage";
      lks = "logkeys -s";
      lkk = "logkeys -k";
      lock = "sudo cryptsetup luksClose";
      lrt = "ligo run test";
      ls = "lsd";
      lsg = "lsd | grep";
      lsr = "lsd -R";
      lsrg = "lsd -R | grep";
      lst = "lsdu --tree";
      lstg = "lsdu --tree | grep";
      mar = "cd ~/development/marigold";
      mc = "./tezos-client --mode mockup --base-dir /tmp/mockup";
      mfix = "mill mono.__.fix --rules OrganizeImports && mill mono._.reformat";
      mkk = "minikube kubectl";
      mksc = "minikube config set cpus 4";
      mksm = "minikube config set memory 6144";
      mksp = "minikube stop";
      mkst = "minikube start";
      nb = "nix build";
      ncg = "nix-collect-garbage -d";
      nconf = "cd ~/development/glottologist/nix-config";
      nd = "nix develop";
      ne = "nix-env";
      news = "newsboat";
      notes = "cd ~/Documents/notes";
      npks = "cd ~/development/glottologist/nixpkgs";
      nr = "nix run";
      ns = "nix-env -q -a --attr-path ";
      nsf = "nix search";
      ont = "cd ~/development/ontologi";
      oss = "cd ~/development/opensource";
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
      syncall = "syncflash && syncknow && synclang && syncnotes && synctemp && syncglot";
      syncflash = "cd ~/Documents/flashcards && git add -A && git commit -am 'Sync flashcards' && git push && cd - ";
      syncglot = "cd ~/development/glottologist/glotzettel && ./copy.sh && git add -A && git commit -am 'Sync content' && git push && cd - ";
      synckeeb = "cd ~/development/glottologist/keeb_layouts && ./copy.sh && git add -A && git commit -am 'Sync keeb config' && git push && cd - ";
      syncknow = "cd ~/Documents/knowledge && git add -A && git commit -am 'Sync knowledge' && git push && cd - ";
      synclang = "cd ~/Documents/languages && git add -A && git commit -am 'Sync languages' && git push && cd - ";
      syncnoah = "cd ~/Documents/noah && git add -A && git commit -am 'Sync noah' && git push && cd - ";
      syncnotes = "cd ~/Documents/notes && git add -A && git commit -am 'Sync notes' && git push && cd - ";
      synctemp = "cd ~/Documents/templates && git add -A && git commit -am 'Sync templates' && git push && cd - ";
      t = "tmux ";
      ta = "tmux attach ";
      tas = "tmux attach -t ";
      tc = "tezos-client";
      tcaa = "tezos-client activate-account";
      tcgb = "tezos-client get balance for";
      tcla = "tezos-client list known addresses";
      testnix = "export NIXPKGS=/home/jason/development/glottologist/nixpkgs && nix-env -f $NIXPKGS -iA";
      tf = "terraform ";
      tk = "cd ~/Documents/tasks && dstask";
      tks = "tmux kill-session -t ";
      tls = "tmux ls ";
      tns = "tmux new-session -s ";
      tree = "exa -T";
      tsk = "cd ~/Documents/tasks && dstask sync && dstask";
      tuk = "cd ~/development/tuktoken";
      unlock = "sudo cryptsetup luksOpen";
      v = "nix run github:glottologist/nvim-flake#developer";
      vd = "vimdiff";
      vn = "nix run ~/development/glottologist/nvim-flake";
      vnd = "nix run ~/development/glottologist/nvim-flake#developer";
      vg = "nix run github:glottologist/nvim-flake";
      vgd = "nix run github:glottologist/nvim-flake#developer";
      vnl = "nix run -I ~/development/glottologist/nvim-flake";
      vpn = "expressvpn";
      vpnc = "expressvpn connect";
      vpnd = "expressvpn disconnect";
      vpnl = "expressvpn ls";
      wat = "watchexec";
      wipe = "lethe wipe -s dod";
      wipedeep = "lethe wipe -s vsitr";
      wipehelp = "lethe wipe --help";
      wipewith = "lethe wipe -s";
      wipezero = "lethe wipe -s zero";
    };
    shellInit = fishConfig;
  };

  xdg.configFile."fish/completions/keytool.fish".text = custom.completions.keytool;
}
