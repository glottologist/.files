# The Omnixy desktop: the upstream tree vendored under desktop/, built into
# the store path the session exports as OMNIXY_PATH. Everything the desktop
# writes at runtime goes to ~/.local/state/omnixy and ~/.config/omnixy, so
# a read-only tree is safe.
{
  lib,
  stdenvNoCC,
  bash,
  python3,
  jq,
  gum,
  ripgrep,
  fzf,
  grim,
  slurp,
  brightnessctl,
  playerctl,
  upower,
  swaybg,
  libnotify,
  wl-clipboard,
  networkmanager,
  bluez,
  gtk3,
  wireplumber,
  quickshell,
  udiskie,
  qrencode,
  hyprsunset,
  inotify-tools,
  xdg-terminal-exec,
  pulseaudio,
  wtype,
  glib,
  desktop-file-utils,
  ddcutil,
  libxkbcommon,
  vips,
  codexbar,
}:
let
  # Arch package name -> the command that proves it is present. The few
  # surviving omnixy-pkg-present callers (about, setup, style.unlock) use
  # this to decide whether a row applies. Unlisted names test themselves.
  pkgCommands = {
    "1password" = "1password";
    "1password-cli" = "op";
    alacritty = "alacritty";
    bitwarden = "bitwarden";
    "brave-bin" = "brave";
    dropbox = "dropbox";
    "dropbox-cli" = "dropbox-cli";
    firefox = "firefox";
    foot = "foot";
    fprintd = "fprintd";
    ghostty = "ghostty";
    "google-chrome" = "google-chrome-stable";
    gum = "gum";
    helix = "hx";
    kitty = "kitty";
    "libfido2" = "fido2-token";
    "pam-u2f" = "pamu2fcfg";
    "signal-desktop" = "signal-desktop";
    spotify = "spotify";
    steam = "steam";
    tailscale = "tailscale";
    "visual-studio-code-bin" = "code";
    "voxtype-bin" = "voxtype";
    zed = "zeditor";
    "nautilus-dropbox" = "";
    libfprint = "";
  };
  pkgCommandCases = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (pkg: cmd: "  ${lib.escapeShellArg pkg}) printf '%s' ${lib.escapeShellArg cmd} ;;") pkgCommands
  );

  # Still reachable from the vendored menu after the Arch sections were cut
  # (about, style.unlock, setup): each declares what NixOS owns and fails.
  systemOwned = [
    "omnixy-migrate"
    "omnixy-provision-first-run"
    "omnixy-update-restart"
    "omnixy-disk-speedtest"
    "omnixy-plymouth-current"
    "omnixy-plymouth-list"
    "omnixy-plymouth-set"
    "omnixy-system-factory-reset"
  ];
in
stdenvNoCC.mkDerivation {
  pname = "omnixy-desktop";
  version = "4.0.2";
  src = ./desktop;

  buildInputs = [ bash python3 ];
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
    chmod -R u+w $out

    stub() {
      cat > "$out/bin/$1" <<EOF
    #!/bin/bash
    notify-send -u normal "Omnixy" "$1: this is declared in the NixOS configuration, not changed at runtime." 2>/dev/null || true
    echo "$1: declared in the NixOS configuration, not changed at runtime" >&2
    exit 1
    EOF
      chmod +x "$out/bin/$1"
    }
    for script in ${lib.concatStringsSep " " systemOwned}; do stub "$script"; done

    cat > $out/bin/omnixy-nix-pkg-command <<'EOF'
    #!/bin/bash
    case "$1" in
    ${pkgCommandCases}
      *) printf '%s' "$1" ;;
    esac
    EOF
    cat > $out/bin/omnixy-pkg-present <<'EOF'
    #!/bin/bash
    for pkg in "$@"; do
      cmd=$(omnixy-nix-pkg-command "$pkg")
      [[ -n $cmd ]] || exit 1
      command -v "$cmd" &>/dev/null || exit 1
    done
    exit 0
    EOF
    cat > $out/bin/omnixy-pkg-missing <<'EOF'
    #!/bin/bash
    for pkg in "$@"; do omnixy-pkg-present "$pkg" || exit 0; done
    exit 1
    EOF
    cat > $out/bin/omnixy-pkg-add <<'EOF'
    #!/bin/bash
    missing=()
    for pkg in "$@"; do omnixy-pkg-present "$pkg" || missing+=("$pkg"); done
    (( ''${#missing[@]} == 0 )) && exit 0
    echo "omnixy-pkg-add: not provided by the flake: ''${missing[*]}" >&2
    exit 1
    EOF
    cp $out/bin/omnixy-pkg-add $out/bin/omnixy-pkg-aur-add
    cat > $out/bin/omnixy-pkg-drop <<'EOF'
    #!/bin/bash
    exit 0
    EOF
    # The bar's system-update widget polls this and reads exit 0 as "an
    # update is waiting"; updates arrive with the flake.
    cat > $out/bin/omnixy-update-available <<'EOF'
    #!/bin/bash
    exit 1
    EOF
    cat > $out/bin/omnixy-update <<'EOF'
    #!/bin/bash
    echo "Omnixy updates arrive with the flake: ./do host apply bebop && ./do home apply glottologist" >&2
    exit 1
    EOF
    cat > $out/bin/omnixy-channel-current <<'EOF'
    #!/bin/bash
    echo nix
    EOF
    cat > $out/bin/omnixy-version-channel <<'EOF'
    #!/bin/bash
    echo "nix (pinned by flake.lock)"
    EOF
    cat > $out/bin/omnixy-version-pkgs <<'EOF'
    #!/bin/bash
    if stamp=$(stat -c %Y /nix/var/nix/profiles/system 2>/dev/null); then
      date -d "@$stamp" "+%A, %B %d %Y at %H:%M"
    else
      echo unknown
    fi
    EOF
    # o.launch prefixes launches with uwsm-app; the session is not uwsm-managed.
    cat > $out/bin/uwsm-app <<'EOF'
    #!/bin/bash
    [[ "$1" == "--" ]] && shift
    exec "$@"
    EOF
    chmod +x $out/bin/omnixy-nix-pkg-command $out/bin/omnixy-pkg-* \
      $out/bin/omnixy-update-available $out/bin/omnixy-update \
      $out/bin/omnixy-channel-current $out/bin/omnixy-version-channel \
      $out/bin/omnixy-version-pkgs $out/bin/uwsm-app

    substituteInPlace $out/bin/omnixy-agent-usage-grok \
      --replace-fail "@codexbar@" "${codexbar}/bin/codexbar"
    patchShebangs $out/bin
  '';

  passthru.runtimePath = lib.makeBinPath [
    jq gum ripgrep fzf grim slurp brightnessctl playerctl upower swaybg
    libnotify wl-clipboard networkmanager bluez
    # gtk-launch, for the app launcher (shell/services/AppLibrary.qml).
    gtk3
    wireplumber quickshell udiskie qrencode hyprsunset
    # inotifywait, for PluginRegistry's watch on ~/.config/omnixy/plugins.
    inotify-tools
    # Every floating terminal goes through xdg-terminal-exec.
    xdg-terminal-exec
    # pactl, for the audio device pickers (pipewire-pulse answers).
    pulseaudio
    # Types the emoji and clipboard selections into the focused window.
    wtype
    # gsettings, for omnixy-display-text-size.
    glib
    # update-desktop-database, after web-app and TUI launcher changes.
    desktop-file-utils
    # External-monitor brightness behind the monitor widget.
    ddcutil
    # xkbcli, read by the keyboard-layout widget.
    libxkbcommon
    # vipsthumbnail, for every row of the image pickers.
    vips
  ];

  meta = {
    description = "The Omnixy quickshell desktop, vendored upstream tree (see desktop/UPSTREAM)";
    homepage = "https://github.com/omacom/omarchy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
