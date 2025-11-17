{
  config,
  pkgs,
  ...
}: let
  # Helper script to manage Zellij sessions (equivalent to tds)
  zds = pkgs.writeShellScriptBin "zds" ''
    #!${pkgs.stdenv.shell}

    # abort if we're already inside a Zellij session
    [ -n "$ZELLIJ" ] && exit 0

    # Capture the current working directory
    CURRENT_DIR=$(pwd)

    # Function to create a new session with predefined tabs
    create_session() {
      local SESSION_NAME=$1
      local WORKING_DIR=$2

      # Create layout file on-the-fly
      LAYOUT_FILE=$(mktemp)
      cat > "$LAYOUT_FILE" << EOF
    layout {
      default_tab_template {
        pane size=1 borderless=true {
          plugin location="zellij:tab-bar"
        }
        children
        pane size=2 borderless=true {
          plugin location="zellij:status-bar"
        }
      }

      tab name="editor" cwd="$WORKING_DIR" focus=true
      tab name="assist" cwd="$WORKING_DIR"
      tab name="watch" cwd="$WORKING_DIR"
      tab name="terminal" cwd="$WORKING_DIR"
      tab name="git" cwd="$WORKING_DIR" {
        pane command="git" {
          args "status"
        }
      }
      tab name="docker" cwd="$WORKING_DIR"
    }
    EOF

      # Check if session already exists
      if ${pkgs.zellij}/bin/zellij list-sessions 2>/dev/null | grep -q "^$SESSION_NAME"; then
        # Session exists, just attach
        ${pkgs.zellij}/bin/zellij attach "$SESSION_NAME"
      else
        # Create new session with layout using options
        ${pkgs.zellij}/bin/zellij options --session-name "$SESSION_NAME" --default-layout "$LAYOUT_FILE"
      fi

      # Clean up
      rm -f "$LAYOUT_FILE"
    }

    # List available sessions
    echo "Available sessions"
    echo "------------------"
    echo "Current directory: $CURRENT_DIR"
    echo " "

    # Get list of sessions
    SESSIONS=$(${pkgs.zellij}/bin/zellij list-sessions 2>/dev/null | grep -v "EXITED" | awk '{print $1}' || echo "")

    # Build options array
    options=("New Session")
    if [ -n "$SESSIONS" ]; then
      while IFS= read -r session; do
        [ -n "$session" ] && options+=("$session")
      done <<< "$SESSIONS"
    fi

    # Present menu
    PS3="Please choose your session: "
    select opt in "''${options[@]}"; do
      case $opt in
        "New Session")
          read -rp "Enter new session name: " SESSION_NAME
          create_session "$SESSION_NAME" "$CURRENT_DIR"
          break
          ;;
        "")
          echo "Invalid selection"
          ;;
        *)
          ${pkgs.zellij}/bin/zellij attach "$opt"
          break
          ;;
      esac
    done
  '';

  # Helper script to send commands to all panes (equivalent to tsa)
  zsa = pkgs.writeShellScriptBin "zsa" ''
    #!${pkgs.stdenv.shell}

    if [ -z "$ZELLIJ" ]; then
      echo "Error: Not in a Zellij session"
      exit 1
    fi

    if [ $# -eq 0 ]; then
      echo "Usage: zsa <command>"
      exit 1
    fi

    CMD="$*"
    echo "Sending '$CMD' to all panes..."

    # Use Zellij's write-chars action to send to all panes
    ${pkgs.zellij}/bin/zellij action write-chars "$CMD"
    ${pkgs.zellij}/bin/zellij action write 10  # newline
  '';
in {
  home.packages = with pkgs; [
    zds
    zsa
  ];

  # Copy theme and config files to Zellij config directory
  xdg.configFile = {
    "zellij/config.kdl".source = ./config.kdl;
    "zellij/themes/latte.kdl".source = ./latte.kdl;
    "zellij/themes/zenbones.kdl".source = ./zenbones.kdl;
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = false;

    settings = {
      # Use Fish shell
      default_shell = "${pkgs.fish}/bin/fish";

      # UI settings
      simplified_ui = false;
      pane_frames = true;

      # Theme - defaults to latte, can switch to zenbones
      theme = "latte";

      # Behavior
      copy_on_select = false;
      scrollback_editor = "${pkgs.neovim}/bin/nvim";
      scroll_buffer_size = 200000;

      # Mouse support
      mouse_mode = true;

      # Pane settings
      ui = {
        pane_frames = {
          rounded_corners = true;
        };
      };
    };
  };
}
