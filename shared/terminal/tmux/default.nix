{
  config,
  lib,
  pkgs,
  ...
}:
let
  plugins = pkgs.tmuxPlugins // pkgs.callPackage ./plugins.nix { };
  tmuxConf = builtins.readFile ./default.conf + builtins.readFile ./latte.conf;
  tds = pkgs.writeShellScriptBin "tds" ''
    [ "$TMUX" == "" ] || exit 0

    CURRENT_DIR=$(pwd)

    create_session() {
      local SESSION_NAME=$1
      local WORKING_DIR=$2

      ${pkgs.tmux}/bin/tmux new-session -d -s "$SESSION_NAME" -n "edit" -c "$WORKING_DIR"
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:2" -n "agent" -c "$WORKING_DIR"
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:3" -n "terminal" -c "$WORKING_DIR"
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:4" -n "src ctl" -c "$WORKING_DIR"
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME:5" -n "containers" -c "$WORKING_DIR"

      ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:4" "git status" C-m
      ${pkgs.tmux}/bin/tmux select-window -t "$SESSION_NAME:1"
      ${pkgs.tmux}/bin/tmux attach-session -t "$SESSION_NAME"
    }

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
  tsa = pkgs.writeShellScriptBin "tsa" ''
    if [ -z "$TMUX" ]; then
      echo "Error: Not in a tmux session"
      exit 1
    fi

    SESSION=$(${pkgs.tmux}/bin/tmux display-message -p '#S')

    if [ $# -eq 0 ]; then
      echo "Usage: tsa <command>"
      exit 1
    fi

    CMD="$*"
    for WINDOW in $(${pkgs.tmux}/bin/tmux list-windows -t "$SESSION" -F "#I"); do
      ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION:$WINDOW" "$CMD" C-m
    done
    echo "Sent '$CMD' to all windows in session '$SESSION'"
  '';
in
{
  home.packages = with pkgs; [
    tds
    tsa
  ];

  # Continuum calls @resurrect-save-script-path from the live tmux server.
  # After a HM switch the old store path is GCed and save.sh exits 127 until
  # the server reloads tmux.conf.
  home.activation.reloadTmux = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ${pkgs.tmux}/bin/tmux info >/dev/null 2>&1; then
      ${pkgs.tmux}/bin/tmux source-file "${config.xdg.configHome}/tmux/tmux.conf"
    fi
  '';

  # Starts a detached server once the desktop is up so continuum restores the
  # last save without anyone opening a terminal, and saves again on the way
  # down. Starting at graphical-session.target rather than default.target
  # gives the restored panes WAYLAND_DISPLAY. The user manager lacks the
  # shell's TMUX_TMPDIR, without which the server would listen on a socket
  # under /tmp that no terminal looks for. A restart on switch would kill
  # every session, so changes wait for the next login. The unit cannot be
  # called tmux.service: with @continuum-boot off, continuum runs
  # `systemctl --user disable tmux.service` on every load, which unlinks it.
  systemd.user.services.tmux-server = {
    Unit = {
      Description = "tmux server with continuum restore";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      X-RestartIfChanged = false;
    };
    Service = {
      Type = "forking";
      Environment = [
        "TMUX_TMPDIR=%t"
        "PATH=/run/wrappers/bin:%h/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin"
      ];
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d";
      ExecStop = [
        "${plugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh quiet"
        "${pkgs.tmux}/bin/tmux kill-server"
      ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Continuum autosaves through a hook it prepends to status-right when it
  # loads. extraConfig lands after the plugins, so the theme's status-right
  # replaced the hook and nothing ever autosaved. Order 600 sits after the
  # Home Manager header (mkBefore) and before the plugin block (default).
  xdg.configFile."tmux/tmux.conf".text = lib.mkOrder 600 tmuxConf;

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
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
      {
        plugin = tmux-menus;
        extraConfig = ''
          # The plugin caches its generated menus in a directory beside its own
          # scripts, which under the store is read-only. Initialisation stops
          # at the failed mkdir and the plugin binds nothing at all, so the
          # cache has to be off here. Menus are then built on each open.
          set -g @menus_use_cache no
        '';
      }
      {
        plugin = fingers;
        extraConfig = ''
          set -g @fingers-key F
        '';
      }
      {
        plugin = tmux-which-key;
        extraConfig = ''
          # Plugin copies config into its store path unless XDG is on, which
          # fails read-only and returns 1 during home-manager reloadTmux.
          set -g @tmux-which-key-xdg-enable 1
          set -g @tmux-which-key-key 'k'
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
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '2' # minutes
        '';
      }
    ];
    terminal = "xterm-256color";
  };
}
