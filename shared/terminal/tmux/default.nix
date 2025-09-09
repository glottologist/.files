{
  config,
  pkgs,
  ...
}: let
  plugins = pkgs.tmuxPlugins // pkgs.callPackage ./plugins.nix {};
  tmuxConf = builtins.readFile ./default.conf + builtins.readFile ./latte.conf;
  tds = pkgs.writeShellScriptBin "tds" ''
    #!${pkgs.stdenv.shell}

    # abort if we're already inside a TMUX session
    [ "$TMUX" == "" ] || exit 0

    # Capture the current working directory
    CURRENT_DIR=$(pwd)

    # Function to create a new session with predefined windows
    create_session() {
      local SESSION_NAME=$1
      local WORKING_DIR=$2

      # Create new session with first window in current directory
      ${pkgs.tmux}/bin/tmux new-session -d -s "$SESSION_NAME" -n "editor" -c "$WORKING_DIR"

      # Create additional windows, all in the current working directory
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:2" -n "assist" -c "$WORKING_DIR"
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:3" -n "watch" -c "$WORKING_DIR"
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:4" -n "terminal" -c "$WORKING_DIR"
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:5" -n "git" -c "$WORKING_DIR"
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:6" -n "docker" -c "$WORKING_DIR"

      # Enable synchronized panes for all windows
      for i in {1..6}; do
        ${pkgs.tmux}/bin/tmux set-window-option -t "$SESSION_NAME:$i" synchronize-panes on
      done

      # Optional: Run git status in the git window
      ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:5" "git status" C-m

      # Select the first window
      ${pkgs.tmux}/bin/tmux select-window -t "$SESSION_NAME:1"

      # Attach to the session
      ${pkgs.tmux}/bin/tmux attach-session -t "$SESSION_NAME"
    }

    # present menu for user to choose which workspace to open
    PS3="Please choose your session: "
    # shellcheck disable=SC2207
    IFS=$'\n' && options=("New Session" $(${pkgs.tmux}/bin/tmux list-sessions -F "#S" 2>/dev/null))
    echo "Available sessions"
    echo "------------------"
    echo "Current directory: $CURRENT_DIR"
    echo " "
    select opt in "''${options[@]}"
    do
        case $opt in
            "New Session")
                read -rp "Enter new session name: " SESSION_NAME
                create_session "$SESSION_NAME" "$CURRENT_DIR"
                break
                ;;
            *)
                ${pkgs.tmux}/bin/tmux attach-session -t "$opt"
                break
                ;;
        esac
    done
  '';
  # Helper script to send commands to all windows
  tsa = pkgs.writeShellScriptBin "tsa" ''
    #!${pkgs.stdenv.shell}

    # Send a command to all windows in the current tmux session
    if [ -z "$TMUX" ]; then
      echo "Error: Not in a tmux session"
      exit 1
    fi

    # Get the current session name
    SESSION=$(${pkgs.tmux}/bin/tmux display-message -p '#S')

    # Get the command to send
    if [ $# -eq 0 ]; then
      echo "Usage: tsa <command>"
      exit 1
    fi

      # Single command mode
      CMD="$*"
      for WINDOW in $(${pkgs.tmux}/bin/tmux list-windows -t "$SESSION" -F "#W"); do
        ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION:$WINDOW" "$CMD" C-m
      done
      echo "Sent '$CMD' to all windows in session '$SESSION'"
  '';
in {
  home.packages = with pkgs; [
    tds
    tsa
  ];

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    extraConfig = tmuxConf;
    escapeTime = 0;
    keyMode = "vi";
    plugins = with plugins; [
      cpu
      battery
      net-speed
      online-status
      sidebar
      sysstat
      tpm
      tmux-menus
      {
        plugin = fingers;
        extraConfig = ''
          set -g @fingers-key F
        '';
      }
      {
        plugin = tmux-which-key;
        extraConfig = ''
          set -g @tmux-which-key-key 'k'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '2' # minutes
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-save 'S'
          set -g @resurrect-restore 'R'
          set -g @resurrect-dir '~/.config/tmux/resurrect'
        '';
      }
    ];
    shortcut = "a";
    terminal = "xterm-256color";
  };
}
