{ lib, config, pkgs, ... }:
let
  gitConfig = {
    core = {
      editor = "nvim";
      pager  = "diff-so-fancy | less --tabs=4 -RFX";
    };
    merge.tool = "vimdiff";
    mergetool = {
      cmd    = "nvim -f -c \"Gvdiffsplit!\" \"$MERGED\"";
      prompt = false;
    };
    pull.rebase = false;

  };
in
{

  programs.git = {
    enable = true;
    aliases = {
          e = "exit";
          s = "status -s -b -uno";
          sh = "show";
          c = "clone";
          m = "merge";
          p = "pull";
          ps = "push";
          rh = "reset --hard";
          rmg = "reset --merge";
          rs = "reset --soft";
          b = "branch";
          ba = "branch -a -v -v";
          bv = "branch -vv";
          br = "branch -r";
          bc = "!git-branch-check";
          bs = "bisect start";
          bg = "bisect good";
          bb = "bisect bad";
          ci = "commit -v -uno";
          cm = "commit -am";
          co = "checkout";
          d = "diff  -C";
          dw = "diff  -C -w";
          ds = "diff  -C --stat";
          dsp = "diff  -C --stat -p";
          dcw = "diff  -C --word-diff";
          du = "diff  -C @{u}";
          dwu = "diff  -C -w @{u}";
          dcwu = "diff  -C --word-diff @{u}";
          l = "log   -C --decorate";
          ls = "log   -C --stat --decorate";
          lh = "log --pretty=format:'%h' -n 1";
          lsp = "log   -C --stat -p --decorate";
          lold = "log --graph --oneline --all --decorate '--format=%h %an %ar %d %s'";
          lgbw = "log   --graph --boundary '--format=%h %ar %d %s'";
          lg = "log   --graph --boundary '--format=%Cred%h%Creset %Clightblue%ar%Creset %Cgreen%ar%Creset %Cred%d%Creset %s'";
          lga = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' --all";
          l19 = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' --all -19";
          lsd = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' --all --simplify-by-decoration";
          lglr = "log   --graph --boundary '--format=%Cred%h%Creset %an %Cgreen%ar%Creset %Cred%d%Creset %s' --boundary --left-right --cherry-pick";
          pom = "push origin master";
          pall = "!git push && !git push --tags";
          rl = "reflog show --date=relative";
          ru = "remote update";
          sl = "stash list";
          sp = "stash pop";
          ss = "stash save";
          sd = "stash drop";
          sa = "stash apply";
          sb = "show-branch";
          sbt = "show-branch --topics";
          sbs = "show-branch --sha1-name";
          ka = "!gitk --all";
          kdo = "!gitk --date-order";
          kado = "!gitk --all --date-order";
          kasd = "!gitk --all --simplify-by-decoration";
          cp = "!git stash save $(date +%F--%T) && git stash pop --index";
          graphviz = "!f() { echo 'digraph git {' ; git log --pretty='format: %h -> { %p }' \"$@\" | sed 's/[0-9a-f][0-9a-f]*/\"&\"/g' ; echo '}'; }; f";
          cat = "-p cat-file -p";
          top = "!eval cd$(pwd)/$(git rev-parse --show-cdup)&& pwd";
          ls-del = "ls-files -d";
          ls-mod = "ls-files -m";
          ls-new = "ls-files --exclude-standard -o";
          ls-ign = "ls-files --exclude-standard -o -i";
          lsfiles = "ls-files --exclude-per-directory=.gitignore \t--exclude-from = .git/info/exclude \tsk = !gitk --date-order $(git stash list | cut -d: -f1) --not --branches --tags --remotes";
          d1 = "!gitk --date-order $(git log -g --pretty=%H) --not --branches --tags --remotes";
          d2 = "!gitk --date-order $(git fsck | grepdangling.commit| cut -f3 -d' ') --not --branches --tags --remotes";

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
      key = "87F1484EE9CA6489";
      signByDefault = true;
    };
    userEmail = "jason@glottologist.co.uk";
    userName = "jason";
  };
}
