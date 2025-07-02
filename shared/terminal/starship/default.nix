{
  fontSize,
  pkgs,
  ...
}: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character.success_symbol = "[λ](bold green)";
      cmd_duration.show_milliseconds = false;
      format = "$all$directory$character";
      right_format = "$all";
      aws.symbol = "";
      buf = {
        symbol = " ";
      };
      battery = {
        full_symbol = " ";
        charging_symbol = " ";
        discharging_symbol = " ";
      };
      c = {
        symbol = " ";
      };
      conda.symbol = " ";
      directory = {
        fish_style_pwd_dir_length = 1; # turn on fish directory truncation
        truncation_length = 2; # number of directories not to truncate
        read_only = " 󰌾";
      };
      dart.symbol = " ";
      docker_context = {
        symbol = " ";
        format = "via [🐋 $context](blue bold)";
      };
      elixir.symbol = " ";
      elm.symbol = " ";
      gcloud.disabled = true;
      git_branch.symbol = " ";
      git_state = {
        rebase = "咽";
        merge = "";
        revert = "";
        cherry_pick = "";
        bisect = "";
        am = "ﯬ";
        am_or_rebase = "ﯬ or 咽";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = " ";
        ahead = " ";
        behind = " ";
        diverged = " ";
        untracked = " ";
        stashed = " ";
        modified = " ";
        staged = " ";
        renamed = " ";
        deleted = " ";
      };
      golang.symbol = " ";
      #haskell.symbol = "λ ";
      hg_branch.symbol = " ";
      hostname = {
        ssh_symbol = " ";
        style = "bold green";
      };
      java.symbol = " ";
      julia.symbol = " ";
      # Disable because it includes cached memory so memory is reported as full a lot
      lua = {
        symbol = " ";
      };
      memory_usage = {
        disabled = false;
        symbol = " ";
        threshold = 90;
        style = "bold blue";
      };
      nim = {
        symbol = "󰆥 ";
      };
      nodejs.symbol = " ";
      ocaml = {
        symbol = " ";
      };
      package = {
        symbol = "󰏗 ";
      };
      perl.symbol = " ";
      php.symbol = " ";
      python.symbol = " ";
      ruby.symbol = " ";
      rust = {
        symbol = " ";
      };
      swift = {
        symbol = " ";
      };
      zig = {
        symbol = " ";
      };
      shell.disabled = false;
      status.disabled = false;
      time = {
        disabled = false;
      };
      username.style_user = "bold blue";
    };
  };
}
