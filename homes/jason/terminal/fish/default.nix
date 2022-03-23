{ config, pkgs, lib, ... }:

let
  fzfConfig = ''
    set -x FZF_DEFAULT_OPTS "--preview='bat {} --color=always'" \n
    set -x SKIM_DEFAULT_COMMAND "rg --files || fd || find ."
  '';

  themeConfig = ''
    set -g theme_display_date no
    set -g theme_display_git_master_branch no
    set -g theme_nerd_fonts yes
    set -g theme_newline_cursor yes
    set -g theme_color_scheme solarized
  '';

  custom = pkgs.callPackage ./plugins.nix {};

  fenv = {
    name = "foreign-env";
    src = pkgs.fishPlugins.foreign-env.src;
  };

  fishConfig = ''
    bind \t accept-autosuggestion
    set fish_greeting
  '' + fzfConfig + themeConfig;
in
{
  programs.fish = {
    enable = true;
    plugins = [ fenv ];
    interactiveShellInit = ''
      eval (direnv hook fish)
      any-nix-shell fish --info-right | source
    '';
    shellAliases = {
      ".-"       = "cd - ";
      ".."       = "cd ..";
      alarm      = "termdown --blink --text 'FINISHED'";
      art        = "cd ~/Documents/articles";
      cat        = "bat";
      cb         = "cargo build";
      cbn        = "cargo bench";
      cc         = "cargo clean";
      cck        = "cargo check";
      cdoc       = "cargo doc";
      cf         = "cargo fmt --all";
      clb        = "cabal build";
      clr        = "clear";
      clrn       = "cabal run";
      clrp       = "cabal repl";
      clt        = "cabal test";
      cn         = "cargo new";
      coin       = "cointop";
      cone       = "cd ~/development/chorusone";
      cprf       = "cp -rf";
      cr         = "cargo run";
      crg        = "crate2nix generate";
      ct         = "cargo test";
      cu         = "cargo update";
      cw         = "cargo watch -s 'clear; cargo check --tests --color=always 2>&1 | head -40'";
      db         = "docker build -t";
      dc         = "docker-compose";
      dcd        = "docker-compose down --remove-orphans";
      dcps       = "docker-compose ps";
      dcu        = "docker-compose up";
      dev        = "cd ~/development";
      di         = "docker images";
      disk       = "sudo diskonaut /";
      doc        = "cd ~/Documents";
      dotb       = "dotnet build";
      dotbat     = "dotnet build && dotnet test";
      dotc       = "dotnet clean";
      dott       = "dotnet test";
      down       = "cd ~/Downloads";
      dps        = "docker ps";
      dpsa       = "docker ps -a";
      dr         = "docker run ";
      dri        = "docker run -it --rm";
      drmi       = "docker rmi --force (docker images | awk '{print $3}')";
      drop       = "cd ~/Dropbox";
      du         = "ncdu --color dark -rr -x";
      flash      = "cd ~/Documents/flashcards";
      fs         = "flameshot gui";
      ga         = "git add";
      gaa        = "git add -A";
      gac        = "git add -A && git commit -am";
      gb         = "git branch";
      gbr        = "git branch -r";
      gc         = "git commit -am ";
      gcf        = "git clean -f";
      gcl        = "git clone ";
      gcn        = "git clean -n";
      gco        = "git checkout ";
      gd         = "git diff ";
      glot       = "cd ~/development/glottologist";
      gp         = "git pull";
      gps        = "git push";
      gpt        = "git push --tags";
      grh        = "git reset --hard HEAD~1";
      grm        = "git reset --merge";
      grs        = "git reset --soft HEAD~1";
      gs         = "git status";
      gsp        = "git stash pop";
      gss        = "git stash save";
      gts        = "cd $HOME/.config/tmux git pull && cd -";
      gus        = "git submodule update --init --recursive";
      gzp        = "cd $HOME/Documents/glotzettel && git add -A && git commit -am 'Sync Zettel' && git push && cd -";
      gzpl       = "cd $HOME/Documents/glotzettel && git pull && cd -";
      h          = "history";
      hg         = "history | grep";
      hm         = "home-manager";
      hmrg       = "home-manager expire-generations 'now'";
      hy         = "history";
      int        = "cd ~/development/intendaglobal";
      intplat    = "cd /development/intendaglobal/platform";
      jak        = "cd ~/development/jakaranda";
      k          = "kubectl ";
      kaf        = "kubectl apply -f";
      kcp        = "kubectl cp ";
      kdn        = "kubectl describe node ";
      kdp        = "kubectl delete pod ";
      kge        = "kubectl get events --sort-by='\'{.lastTimestamp}'\' ";
      kgn        = "kubectl get nodes";
      kgp        = "kubectl get pod ";
      kl         = "kubectl logs ";
      kn         = "kubens ";
      know       = "cd ~/Documents/knowledge";
      kpf        = "kubectl port-forward ";
      kx         = "kubectx ";
      lang       = "cd ~/Documents/languages";
      lar        = "ls -laR";
      ll         = "ls -a";
      lock       = "sudo cryptsetup luksClose";
      ls         = "lsd";
      mar        = "cd ~/development/marigold";
      mfix       = "mill mono.__.fix --rules OrganizeImports && mill mono._.reformat";
      mkk        = "minikube kubectl";
      mksc       = "minikube config set cpus 4";
      mksm       = "minikube config set memory 6144";
      mksp       = "minikube stop";
      mkst       = "minikube start";
      nb         = "nix build";
      ncg        = "nix-collect-garbage";
      nconf      = "cd ~/development/glottologist/nix-config";
      nd         = "nix develop";
      ne         = "nix-env";
      news       = "newsboat";
      notes      = "cd ~/Documents/notes";
      npks       = "cd ~/development/glottologist/nixpkgs";
      nse        = "nix search ";
      ont        = "cd ~/development/ontologi";
      oss        = "cd ~/development/opensource";
      ping       = "prettyping";
      pres       = "cd ~/Documents/presentations";
      pullall    = "find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;";
      recr       = "cd ~/development/glottologist/recruitment";
      ref        = "cd ~/development/reference";
      rmcaps     = "xmodmap -e 'remove lock = Caps_Lock' && xmodmap -e 'keysym Caps_Lock = Control space'";
      rmp        = "rmapi put";
      scr        = "cd ~/development/scratch";
      setmtu     = "sudo ip link set dev eth0 mtu 1350";
      space      = "sudo ncdu -x /";
      sts        = "cd $HOME/.config/tmux && git add -A && git commit -am 'Sync sessions' && git push && cd -";
      syncall    = "syncart && syncflash && syncknow && syncnotes && syncpres && synctemp ";
      syncart    = "cd ~/Documents/articles && git add -A && git commit -am 'Sync articles' && git push && cd - ";
      syncflash  = "cd ~/Documents/flashcards && git add -A && git commit -am 'Sync flashcards' && git push && cd - ";
      syncknow   = "cd ~/Documents/knowledge && git add -A && git commit -am 'Sync knowledge' && git push && cd - ";
      syncnotes  = "cd ~/Documents/notes && git add -A && git commit -am 'Sync notes' && git push && cd - ";
      syncpres   = "cd ~/Documents/presentations && git add -A && git commit -am 'Sync presentations' && git push && cd - ";
      synctemp   = "cd ~/Documents/templates && git add -A && git commit -am 'Sync templates' && git push && cd - ";
      t          = "tmux ";
      ta         = "tmux attach ";
      tas        = "tmux attach -t ";
      testnix    = "export NIXPKGS=/home/jason/development/glottologist/nixpkgs && nix-env -f $NIXPKGS -iA";
      tf         = "terraform ";
      tk         = "cd ~/Documents/tasks && dstask";
      tks        = "tmux kill-session -t ";
      tls        = "tmux ls ";
      tns        = "tmux new-session -s ";
      tree       = "exa -T";
      tsk        = "cd ~/Documents/tasks && dstask sync && dstask";
      unlock     = "sudo cryptsetup luksOpen";
      v          = "nvim ";
      vd         = "vimdiff";
      wipe       = "lethe wipe -s dod";
      wipedeep   = "lethe wipe -s vsitr";
      wipehelp   = "lethe wipe --help";
      wipewith   = "lethe wipe -s";
      wipezero   = "lethe wipe -s zero";
    };
     shellInit = fzfConfig ;

  };

  xdg.configFile."fish/completions/keytool.fish".text = custom.completions.keytool;

}

