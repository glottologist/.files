{
  lib,
  config,
  pkgs,
  ...
}: let
  gitConfig = {
    core = {
      editor = "vim";
      #pager = "delta";
    };
    merge.tool = "vimdiff";
    mergetool = {
      cmd = "vim -f -c \"Gvdiffsplit!\" \"$MERGED\"";
      prompt = false;
    };
    pull.rebase = true;
    push.autoSetupRemote = true;
    init.defaultBranch = "main";
    commit.gpgSign = lib.mkDefault true;
    gpg.program = "${config.programs.gpg.package}/bin/gpg2";
      commit.verbose = true;
      diff.algorithm = "histogram";
      log.date = "iso";
      column.ui = "auto";
      branch.sort = "committerdate";
      rerere.enabled = true;
  };
in {
  home.packages = with pkgs.gitAndTools; [
    act # run GH actions locally
    #diff-so-fancy # git diff with colors
    #commitizen #Tool to create committing rules for projects, auto bump versions, and generate changelogs
    #cz-cli #The commitizen command line utility
    gh # gh command line
    gist # upload code to gist
    git-crypt # git files encryption
    git-cliff # Highly customizable Changelog Generator that follows Conventional Commit specifications
    git-ignore # get ignore files
    gitea # Git with a cup of tea
    git-open # open repo in browser
    git-review # submit to gerrit
    github-commenter #
    gitwatch
    hub # github command-line client
    tea # CLI for gitea
    tig # diff and commit view
    vim #editor for git messages
    opencommit #AI-powered commit message generator
    debase #TUI for drag-and-drop manipulation of git commits
    serie # A rich git commit graph in your terminal, like magic
  ];

  programs.git = {
    enable = true;
    aliases = {
      b = "branch";
      ba = "branch -a -v -v";
      bb = "bisect bad";
      bc = "!git-branch-check";
      bg = "bisect good";
      br = "branch -r";
      bs = "bisect start";
      bv = "branch -vv";
      c = "clone";
      cat = "-p cat-file -p";
      ci = "commit -v -uno";
      cm = "commit -am";
      co = "checkout";
      cp = "!git stash save $(date +%F--%T) && git stash pop --index";
      d = "diff  -C";
      d1 = "!gitk --date-order $(git log -g --pretty=%H) --not --branches --tags --remotes";
      d2 = "!gitk --date-order $(git fsck | grepdangling.commit| cut -f3 -d' ') --not --branches --tags --remotes";
      dcw = "diff  -C --word-diff";
      dcwu = "diff  -C --word-diff @{u}";
      ds = "diff  -C --stat";
      dsp = "diff  -C --stat -p";
      du = "diff  -C @{u}";
      dw = "diff  -C -w";
      dwu = "diff  -C -w @{u}";
      e = "exit";
      graphviz = "!f() { echo 'digraph git {' ; git log --pretty='format: %h -> { %p }' \"$@\" | sed 's/[0-9a-f][0-9a-f]*/\"&\"/g' ; echo '}'; }; f";
      ka = "!gitk --all";
      kado = "!gitk --all --date-order";
      kasd = "!gitk --all --simplify-by-decoration";
      kdo = "!gitk --date-order";
      l = "log   -C --decorate";
      l19 = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' -19";
      la19 = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' --all -19";
      lg = "log   --graph --boundary '--format=%Cred%h%Creset %Clightblue%ar%Creset %Cgreen%ar%Creset %Cred%d%Creset %s'";
      lga = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' --all";
      lgbw = "log   --graph --boundary '--format=%h %ar %d %s'";
      lglr = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' --boundary --left-right --cherry-pick";
      lh = "log --pretty=format:'%h' -n 1";
      lold = "log --graph --oneline --all --decorate '--format=%h %an %ar %d %s'";
      ls = "log   -C --stat --decorate";
      ls-del = "ls-files -d";
      ls-ign = "ls-files --exclude-standard -o -i";
      ls-mod = "ls-files -m";
      ls-new = "ls-files --exclude-standard -o";
      lsd = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' --all --simplify-by-decoration";
      lsfiles = "ls-files --exclude-per-directory=.gitignore \t--exclude-from = .git/info/exclude \tsk = !gitk --date-order $(git stash list | cut -d: -f1) --not --branches --tags --remotes";
      lsp = "log   -C --stat -p --decorate";
      m = "merge";
      p = "pull";
      pall = "!git push && !git push --tags";
      pom = "push origin master";
      ps = "push";
      rh = "reset --hard";
      rl = "reflog show --date=relative";
      rmg = "reset --merge";
      rs = "reset --soft";
      ru = "remote update";
      s = "status -s -b -uno";
      sa = "stash apply";
      sb = "show-branch";
      sbs = "show-branch --sha1-name";
      sbt = "show-branch --topics";
      sd = "stash drop";
      sh = "show";
      sl = "stash list";
      smu = "submodule update --init --recursive";
      sp = "stash pop";
      ss = "stash save";
      top = "!eval cd$(pwd)/$(git rev-parse --show-cdup)&& pwd";
    };
    extraConfig = gitConfig;
    ignores = [
      "*.bloop"
      "*.metals"
      "*.metals.sbt"
      "*metals.sbt"
      "*.direnv"
      "*.envrc"
      "*.mill-version" # used by metals
    ];
    signing = {
      key = "7AE4A895BF993A8B";
      signByDefault = true;
    };
    diff-so-fancy = {
      enable = false;
    };
    delta = {
      enable = true;
    };
    userEmail = "jason@ridgway-taylor.co.uk";
    userName = "jason";
  };
}
