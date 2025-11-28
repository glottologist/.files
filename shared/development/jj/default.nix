{
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];

  programs.jujutsu = {
    enable = true;
    settings = {
      core.fsmonitor = "watchman";
      format.tree-level-conflicts = true;

      aliases = {
        df = ["diff"];

        lm = [
          "log"
          "-r"
          "present(@) | present(ancestors(bookmarks() & mine() & mutable(), 5))"
        ];

        mv = [
          "b"
          "s"
          "-r"
        ];

        gp = [
          "git"
          "push"
        ];

        rba = [
          "rebase"
          "-b"
          "all:(mine() & mutable() & bookmarks())"
          "-d"
        ];
      };

      user = {
        name = config.programs.git.settings.user.name;
        email = config.programs.git.settings.user.email;
      };
      git = {
        fetch = [
          "upstream"
          "origin"
        ];

        push = "origin";
        push-bookmark-prefix = "moni/";
        auto-local-bookmark = true;
      };
      signing = let
        gitCfg = config.programs.git.settings;
      in {
        backend = "gpg";
        behaviour =
          if gitCfg.commit.gpgSign
          then "own"
          else "never";
        key = config.programs.git.signing.key;
      };

      merge-tools.diffconflicts = {
        program = "vim";
        merge-tool-edits-conflict-markers = true;

        merge-args = [
          "-c"
          "let g:jj_diffconflicts_marker_length=$marker_length"
          "-c"
          "JJDiffConflicts!"
          "$output"
          "$base"
          "$left"
          "$right"
        ];
      };

      templates = {
        log = ''
          if(root,
            separate(" ",
              format_short_change_id(self.change_id()),
              format_short_commit_id(self.commit_id()),
              label("root", "root()"),
              self.bookmarks(),
            ) ++ "\n",
            label(if(current_working_copy, "working_copy"),
              concat(
                separate(" ",
                  if(self.conflict(), label("conflict", "conflict")),
                  if(!empty, label("empty", "∆")),
                  if(empty && self.parents().len() > 1, label("empty", "git-merge")),
                  format_short_change_id_with_hidden_and_divergent_info(self),
                  format_short_commit_id(self.commit_id()),
                  self.bookmarks(),
                  self.tags(),
                  self.working_copies(),
                  if(self.git_head(), label("git_head", "git_head()")),
                  commit_timestamp(self).local().format("%Y-%m-%d"),
                  if(author.name() && author.email(), concat("by ", separate(" as ", author.email().local(), author.name()))),
                  if(author.name() && !author.email(), author.name()),
                  if(!author.name() && author.email(), author.email().local()),
                  if(!author.name() && !author.email(), email_placeholder),
                  if(config("ui.show-cryptographic-signatures").as_boolean(),
                    format_short_cryptographic_signature(self.signature())),
                )
                ++ "\n",
                if(description, description.first_line() ++ "\n"),
              ),
            )
          ) ++ "\n"
        '';

        log_node = ''
          coalesce(
            if(!self, label("elided", "▬")),
            label(
              separate(" ",
                if(current_working_copy, "working_copy"),
                if(immutable, "immutable"),
                if(conflict, "conflict"),
              ),
              coalesce(
                if(current_working_copy, "►"),
                if(root, "⌂"),
                if(immutable, "■"),
                if(conflict, "▼"),
                "□",
              )
            )
          )
        '';

        op_log_node = ''
          coalesce(
            if(current_operation, label("current_operation", "►")),
            "□",
          )
        '';
      };

      ui = {
        editor = "vim";
        graph.style = "square";
        show-cryptographic-signatures = false;

        default-command = [
          "log"
          "-r"
          "present(@) | ancestors(remote_bookmarks().., 2) | present(trunk()) | reachable(@, all())"
          "-n"
          "8"
        ];

        diff.tool = [
          "${lib.getExe pkgs.difftastic}"
          "--color=always"
          "$left"
          "$right"
        ];

        diff-editor = [
          "vim"
          "-c"
          "DiffEditor $left $right $output"
        ];

        paginate = "never";
      };
    };
  };
}
