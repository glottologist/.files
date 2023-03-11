{ config, pkgs, lib, ... }:

let
  fzfConfig = ''
    set -x SKIM_DEFAULT_COMMAND "rg --files || fd || find ."
  '';

  themeConfig = ''
    set -g theme_display_date yes
    set -g theme_display_git_master_branch yes
    set -g theme_nerd_fonts yes
    set -g theme_newline_cursor yes
    set -g theme_color_scheme monolace
    set -U fish_color_normal normal
    set -U fish_color_command 000000
    set -U fish_color_quote 626262
    set -U fish_color_redirection 8a8a8a
    set -U fish_color_end 767676
    set -U fish_color_error b2b2b2
    set -U fish_color_param 303030
    set -U fish_color_comment 4e4e4e
    set -U fish_color_match --background=brblue
    set -U fish_color_selection white --bold --background=brblack
    set -U fish_color_search_match bryellow --background=brblack
    set -U fish_color_history_current --bold
    set -U fish_color_operator 00a6b2
    set -U fish_color_escape 00a6b2
    set -U fish_color_cwd green
    set -U fish_color_cwd_root red
    set -U fish_color_valid_path --underline
    set -U fish_color_autosuggestion 777777
    set -U fish_color_user brgreen
    set -U fish_color_host normal
    set -U fish_color_cancel --reverse
    set -U fish_pager_color_prefix normal --bold --underline
    set -U fish_pager_color_progress brwhite --background=cyan
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description B3A06D
    set -U fish_pager_color_selected_background --background=brblack
    set -U fish_pager_color_secondary_completion
    set -U fish_pager_color_secondary_background
    set -U fish_pager_color_secondary_prefix
    set -U fish_color_host_remote
    set -U fish_pager_color_secondary_description
    set -U fish_pager_color_selected_completion
    set -U fish_pager_color_selected_prefix
    set -U fish_color_option
    set -U fish_pager_color_background
    set -U fish_color_keyword
    set -U fish_pager_color_selected_description
  '';

  custom = pkgs.callPackage ./plugins.nix {};

  fenv = {
    name = "foreign-env";
    src = pkgs.fishPlugins.foreign-env.src;
  };

  fishConfig = ''
    bind \t accept-autosuggestion
    set fish_greeting
  '' + themeConfig + fzfConfig;
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
      boox       = "cd ~/Ontologi Dropbox/Jason Ridgway-Taylor/DOCUMENTS/Personal/Boox/";
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
      dka        = "docker kill (docker ps | awk '{print $1}' | grep -v CONTAINER)";
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
      dut        = "dune exec ./main.exe -- test";
      eo         = "eval (opam env)";
      eop        = "eval (opam env)";
      exe        = "cd ~/development/exercism";
      flash      = "cd ~/Documents/flashcards";
      fs         = "flameshot gui";
      ftc        = "docker exec flex tezos-client";
      ga         = "git add";
      gaa        = "git add -A";
      gac        = "git add -A && git commit -am";
      gb         = "git branch";
      gbr        = "git branch -r";
      gc         = "git commit -am ";
      gcf        = "git clean -f";
      gcl        = "git clone ";
      gclb       = "git clone --bare ";
      gclgh      = "git clone git@github.com:";
      gcn        = "git clean -n";
      gco        = "git checkout ";
      gd         = "git diff ";
      gl         = "git l19";
      glot       = "cd ~/development/glottologist";
      gls        = "git ls-files";
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
      gwa        = "git worktree add";
      gwl        = "git worktree list";
      gwlk       = "git worktree lock";
      gwm        = "git worktree move";
      gwp        = "git worktree prune";
      gwr        = "git worktree remove";
      gwrp       = "git worktree repair";
      gwu        = "git worktree unlock";
      h          = "history";
      hg         = "history | grep";
      hm         = "home-manager";
      hmrg       = "home-manager expire-generations 'now'";
      hy         = "history";
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
      lcc        = "ligo compile contract";
      lce        = "ligo compile expression";
      lcp        = "ligo compile parameter";
      lcs        = "ligo compile storage";
      lg         = "ls | grep";
      ll         = "ls -a";
      lock       = "sudo cryptsetup luksClose";
      lrt        = "ligo run test";
      ls         = "lsd";
      mar        = "cd ~/development/marigold";
      mc         = "./tezos-client --mode mockup --base-dir /tmp/mockup";
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
      nr         = "nix run";
      nse        = "nix search ";
      nsp        = "nix search nixpkgs ";
      ont        = "cd ~/development/ontologi";
      oss        = "cd ~/development/opensource";
      ping       = "prettyping";
      pres       = "cd ~/Documents/presentations";
      pullall    = "find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;";
      recr       = "cd ~/development/glottologist/recruitment";
      ref        = "cd ~/development/reference";
      rf         = "rofi -show drun -show-icons";
      rmcaps     = "xmodmap -e 'remove lock = Caps_Lock' && xmodmap -e 'keysym Caps_Lock = Control space'";
      rmp        = "rmapi put";
      scr        = "cd ~/development/scratch";
      setmtu     = "sudo ip link set dev eth0 mtu 1350";
      space      = "sudo ncdu -x /";
      st         = "speedtest";
      sts        = "cd $HOME/.config/tmux && git add -A && git commit -am 'Sync sessions' && git push && cd -";
      syncall    = "syncflash && syncknow && synclang && syncnotes && synctemp && syncglot";
      syncflash  = "cd ~/Documents/flashcards && git add -A && git commit -am 'Sync flashcards' && git push && cd - ";
      syncglot   = "cd ~/development/glottologist/glotzettel && ./copy.sh && git add -A && git commit -am 'Sync content' && git push && cd - ";
      synckeeb   = "cd ~/development/glottologist/keeb_layouts && ./copy.sh && git add -A && git commit -am 'Sync keeb config' && git push && cd - ";
      syncknow   = "cd ~/Documents/knowledge && git add -A && git commit -am 'Sync knowledge' && git push && cd - ";
      synclang   = "cd ~/Documents/languages && git add -A && git commit -am 'Sync languages' && git push && cd - ";
      syncnotes  = "cd ~/Documents/notes && git add -A && git commit -am 'Sync notes' && git push && cd - ";
      synctemp   = "cd ~/Documents/templates && git add -A && git commit -am 'Sync templates' && git push && cd - ";
      t          = "tmux ";
      ta         = "tmux attach ";
      tas        = "tmux attach -t ";
      tc         = "tezos-client";
      tcaa       = "tezos-client activate-account";
      tcgb       = "tezos-client get balance for";
      tcla       = "tezos-client list known addresses";
      testnix    = "export NIXPKGS=/home/jason/development/glottologist/nixpkgs && nix-env -f $NIXPKGS -iA";
      tf         = "terraform ";
      tk         = "cd ~/Documents/tasks && dstask";
      tks        = "tmux kill-session -t ";
      tls        = "tmux ls ";
      tns        = "tmux new-session -s ";
      tree       = "exa -T";
      tsk        = "cd ~/Documents/tasks && dstask sync && dstask";
      tuk        = "cd ~/development/tuktoken";
      unlock     = "sudo cryptsetup luksOpen";
      v          = "nix run github:glottologist/neovim-flake";
      vd         = "vimdiff";
      wipe       = "lethe wipe -s dod";
      wipedeep   = "lethe wipe -s vsitr";
      wipehelp   = "lethe wipe --help";
      wipewith   = "lethe wipe -s";
      wipezero   = "lethe wipe -s zero";
    };
     shellInit = themeConfig +  fzfConfig  ;
  };

  xdg.configFile."fish/completions/keytool.fish".text = custom.completions.keytool;
  xdg.configFile."fish/functions/fish_prompt.fish".text = builtins.readFile ./fish_prompt.fish;

}

