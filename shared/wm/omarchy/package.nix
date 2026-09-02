# Omarchy 4 vendored tree, adapted to NixOS. The store path is the
# session's OMARCHY_PATH; everything omarchy writes at runtime goes to
# ~/.local/state/omarchy and ~/.config/omarchy, so read-only is safe.
{
  lib,
  stdenvNoCC,
  omarchy-src,
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
}: let
  # Arch package name -> the command that proves it is present. Omarchy asks
  # `omarchy-pkg-present <arch-name>` to decide whether an Install or a Remove
  # menu row applies, so the reimplemented predicate below needs a translation
  # from Arch naming to something answerable on NixOS. Only names the menu and
  # the omarchy-install-*/omarchy-remove-* scripts actually pass are listed;
  # anything unlisted falls back to testing the name itself as a command.
  #
  # Arch packages that ship no command of their own -- libraries, PHP
  # extensions, kernel modules, font and data packages -- map to the empty
  # string and are always reported absent. That keeps their Install rows
  # visible (where the action now fails with a Nix-specific message) and their
  # Remove rows hidden, which is the safe direction for a declarative system.
  pkgCommands = {
    "1password" = "1password";
    "1password-cli" = "op";
    alacritty = "alacritty";
    bitwarden = "bitwarden";
    "brave-bin" = "brave";
    "brave-origin-bin" = "brave-origin";
    composer = "composer";
    "cursor-bin" = "cursor";
    dropbox = "dropbox";
    "dropbox-cli" = "dropbox-cli";
    firefox = "firefox";
    flatpak = "flatpak";
    foot = "foot";
    fprintd = "fprintd";
    freerdp = "xfreerdp3";
    fwupd = "fwupdmgr";
    ghostty = "ghostty";
    "google-chrome" = "google-chrome-stable";
    "grok-bot" = "grok-bot";
    gum = "gum";
    # nixpkgs' helix installs the binary as hx only.
    helix = "hx";
    "heroic-games-launcher-bin" = "heroic";
    kitty = "kitty";
    "libfido2" = "fido2-token";
    "lmstudio-bin" = "lm-studio";
    lutris = "lutris";
    "microsoft-edge-stable-bin" = "microsoft-edge-stable";
    "minecraft-launcher" = "minecraft-launcher";
    "nordvpn-bin" = "nordvpn";
    "omarchy-emacs" = "emacs";
    omazed = "omazed";
    "once-bin" = "once";
    "openai-codex-desktop" = "openai-codex-desktop";
    "openbsd-netcat" = "nc";
    openssh = "ssh";
    "pam-u2f" = "pamu2fcfg";
    php = "php";
    retroarch = "retroarch";
    rlwrap = "rlwrap";
    "signal-desktop" = "signal-desktop";
    spotify = "spotify";
    steam = "steam";
    "sublime-text-4" = "subl";
    sunshine = "sunshine";
    supergfxctl = "supergfxctl";
    "symfony-cli" = "symfony";
    tailscale = "tailscale";
    "umu-launcher" = "umu-run";
    vim = "vim";
    "visual-studio-code-bin" = "code";
    "voxtype-bin" = "voxtype";
    "wine-staging" = "wine";
    winetricks = "winetricks";
    wtype = "wtype";
    ydotool = "ydotool";
    zed = "zeditor";
    "zen-browser-bin" = "zen-browser";
    # No command of their own.
    "libappindicator-gtk3" = "";
    libfprint = "";
    "libfprint-git" = "";
    libyaml = "";
    "linux-headers" = "";
    "nautilus-dropbox" = "";
    "php-sqlite" = "";
    "python-gpgme" = "";
    "python-protobuf" = "";
    "wine-gecko" = "";
    "wine-mono" = "";
    xdebug = "";
    "xpadneo-dkms" = "";
  };

  pkgCommandCases = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (pkg: cmd: "  ${lib.escapeShellArg pkg}) printf '%s' ${lib.escapeShellArg cmd} ;;") pkgCommands
  );

  # Scripts that drive pacman/yay directly, or that exist to manage Arch
  # mirrors, channels, migrations and provisioning. NixOS owns all of that
  # through the flake, so each becomes a stub that says so and fails, rather
  # than reporting a success that never happened.
  #
  # The omarchy-install-*/omarchy-remove-* families are deliberately absent:
  # they reach Arch only through the omarchy-pkg-* helpers reimplemented
  # below, so they now succeed for anything the flake already provides and
  # fail with a Nix-specific message for anything it does not.
  archSystemOnly = [
    "omarchy-channel-set"
    "omarchy-debug"
    "omarchy-dev-install-ydoo"
    "omarchy-dev-pkg-test"
    "omarchy-migrate"
    "omarchy-pkg-aur-accessible"
    "omarchy-pkg-aur-install"
    "omarchy-pkg-install"
    "omarchy-pkg-remove"
    "omarchy-provision-first-run"
    "omarchy-provision-owner"
    "omarchy-refresh-pacman"
    "omarchy-reinstall-pkgs"
    "omarchy-remove-dev-env"
    "omarchy-update-aur-pkgs"
    "omarchy-update-keyring"
    "omarchy-update-orphan-pkgs"
    "omarchy-update-pacman-guard"
    "omarchy-update-pkg-prune"
    "omarchy-update-restart"
    "omarchy-update-system-pkgs"
    "omarchy-update-system-pkgs-when-conflicted"
    "omarchy-upgrade-to-quattro"
    "omarchy-upload-log"
  ];

  # The boot splash and the root filesystem are NixOS' to declare
  # (boot.plymouth, fileSystems), and root here is ext4 rather than the btrfs
  # subvolume layout omarchy's snapshot and hibernation scripts assume.
  systemOwnedOnly = [
    "omarchy-disk-speedtest"
    "omarchy-hibernation-remove"
    "omarchy-hibernation-setup"
    "omarchy-plymouth-current"
    "omarchy-plymouth-list"
    "omarchy-plymouth-preview"
    "omarchy-plymouth-set"
    "omarchy-system-factory-reset"
    "omarchy-system-factory-reset-finish"
  ];
in
  stdenvNoCC.mkDerivation {
    pname = "omarchy-nixified";
    version = "4.0.2";
    src = omarchy-src;

    buildInputs = [bash python3];
    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cp -r . $out/
      chmod -R u+w $out

      stub() {
        local name="$1" reason="$2"
        cat > "$out/bin/$name" <<EOF
      #!/bin/bash
      notify-send -u normal "Omarchy on NixOS" "$name: $reason" 2>/dev/null || true
      echo "$name: $reason" >&2
      exit 1
      EOF
        chmod +x "$out/bin/$name"
      }

      for script in ${lib.concatStringsSep " " archSystemOnly}; do
        stub "$script" "Arch package management is unavailable here; declare the package in the flake instead."
      done

      for script in ${lib.concatStringsSep " " systemOwnedOnly}; do
        stub "$script" "this is declared in the NixOS configuration, not changed at runtime."
      done

      # Package presence is answerable on NixOS by resolving the command an
      # Arch package would have installed. The Install and Remove menu rows
      # gate on these two predicates, so a truthful answer is what makes those
      # sections reflect what the flake actually provides.
      cat > $out/bin/omarchy-nix-pkg-command <<'EOF'
      #!/bin/bash
      # Print the command that proves the named Arch package is present, or
      # nothing when the package ships no command of its own.
      case "$1" in
      ${pkgCommandCases}
        *) printf '%s' "$1" ;;
      esac
      EOF
      chmod +x $out/bin/omarchy-nix-pkg-command

      cat > $out/bin/omarchy-pkg-present <<'EOF'
      #!/bin/bash
      # omarchy:summary=Returns true if all of the named packages are installed on the system (or false if any of them are missing).
      # omarchy:args=<packages...>
      for pkg in "$@"; do
        cmd=$(omarchy-nix-pkg-command "$pkg")
        [[ -n $cmd ]] || exit 1
        command -v "$cmd" &>/dev/null || exit 1
      done
      exit 0
      EOF
      chmod +x $out/bin/omarchy-pkg-present

      cat > $out/bin/omarchy-pkg-missing <<'EOF'
      #!/bin/bash
      # omarchy:summary=Returns true if any of the named packages are missing from the system (or false if they're all there).
      # omarchy:args=<packages...>
      for pkg in "$@"; do
        omarchy-pkg-present "$pkg" || exit 0
      done
      exit 1
      EOF
      chmod +x $out/bin/omarchy-pkg-missing

      # Installation is declarative here, so "add" can only report on what the
      # flake already provides. Succeeding when everything named is present
      # preserves upstream's install-if-missing contract, which is what lets
      # the whole omarchy-install-* family keep working for declared packages
      # -- omarchy-install-service-signal, say, goes on to do its non-package
      # setup instead of dying on a stub.
      cat > $out/bin/omarchy-pkg-add <<'EOF'
      #!/bin/bash
      # omarchy:summary=Install Arch packages if they are missing
      # omarchy:args=<packages...>
      missing=()
      for pkg in "$@"; do
        omarchy-pkg-present "$pkg" || missing+=("$pkg")
      done
      (( ''${#missing[@]} == 0 )) && exit 0
      msg="Not provided by the flake: ''${missing[*]}. Declare it in the NixOS configuration and rebuild."
      notify-send -u normal "Omarchy on NixOS" "$msg" 2>/dev/null || true
      echo "omarchy-pkg-add: $msg" >&2
      exit 1
      EOF
      chmod +x $out/bin/omarchy-pkg-add

      # The AUR has no NixOS counterpart, but the packages it carries may well
      # be in nixpkgs under another name, so the same presence test applies.
      cp $out/bin/omarchy-pkg-add $out/bin/omarchy-pkg-aur-add

      cat > $out/bin/omarchy-pkg-drop <<'EOF'
      #!/bin/bash
      # omarchy:summary=Remove all the named packages from the system if they're installed (otherwise ignore).
      # omarchy:args=<packages...>
      present=()
      for pkg in "$@"; do
        omarchy-pkg-present "$pkg" && present+=("$pkg")
      done
      (( ''${#present[@]} == 0 )) && exit 0
      msg="Still provided by the flake: ''${present[*]}. Remove it from the NixOS configuration and rebuild."
      notify-send -u normal "Omarchy on NixOS" "$msg" 2>/dev/null || true
      echo "omarchy-pkg-drop: $msg" >&2
      exit 1
      EOF
      chmod +x $out/bin/omarchy-pkg-drop

      # The bar's omarchy.system-update widget polls this every six hours and
      # treats exit 0 as "an update is waiting". Updates arrive through the
      # flake, so the honest answer is always "nothing pending" -- and a stub
      # exiting 0 would pin the indicator on and fire a notification each poll.
      cat > $out/bin/omarchy-update-available <<'EOF'
      #!/bin/bash
      # omarchy:summary=Check whether Omarchy updates are available.
      exit 1
      EOF
      chmod +x $out/bin/omarchy-update-available

      cat > $out/bin/omarchy-update <<'EOF'
      #!/bin/bash
      # omarchy:summary=Update Omarchy and the system.
      echo "Omarchy updates arrive with the flake on this system." >&2
      echo "Run: cd ~/development/glottologist/.files && ./do host apply <host>" >&2
      exit 1
      EOF
      chmod +x $out/bin/omarchy-update

      cat > $out/bin/omarchy-channel-current <<'EOF'
      #!/bin/bash
      # omarchy:summary=Print the active Omarchy package channel
      echo nix
      EOF
      chmod +x $out/bin/omarchy-channel-current

      cat > $out/bin/omarchy-version-channel <<'EOF'
      #!/bin/bash
      # omarchy:summary=Print the active Omarchy mirror and package channel
      echo "nix (pinned by flake.lock)"
      EOF
      chmod +x $out/bin/omarchy-version-channel

      cat > $out/bin/omarchy-version-pkgs <<'EOF'
      #!/bin/bash
      # omarchy:summary=Print when system packages were last upgraded
      # -c rather than -Lc: the symlink carries the switch time, while the
      # store path it points at is stamped at the epoch.
      if stamp=$(stat -c %Y /nix/var/nix/profiles/system 2>/dev/null); then
        date -d "@$stamp" "+%A, %B %d %Y at %H:%M"
      else
        echo unknown
      fi
      EOF
      chmod +x $out/bin/omarchy-version-pkgs

      # o.launch prefixes launches with uwsm-app; the session is not
      # uwsm-managed, so run the command directly.
      cat > $out/bin/uwsm-app <<'EOF'
      #!/bin/bash
      [[ "$1" == "--" ]] && shift
      exec "$@"
      EOF
      chmod +x $out/bin/uwsm-app

      patchShebangs $out/bin
    '';

    passthru.runtimePath = lib.makeBinPath [
      jq
      gum
      ripgrep
      fzf
      grim
      slurp
      brightnessctl
      playerctl
      upower
      swaybg
      libnotify
      wl-clipboard
      networkmanager
      bluez
      # The quickshell app launcher resolves desktop entries through
      # gtk-launch (shell/services/AppLibrary.qml); without it every
      # launch shows the OSD then dies on command-not-found.
      gtk3
      wireplumber
      quickshell
      udiskie
      qrencode
      hyprsunset
      # PluginRegistry watches ~/.config/omarchy/plugins with inotifywait
      # and respawns the watcher every second when the binary is missing.
      inotify-tools
      # Every floating terminal omarchy opens goes through xdg-terminal-exec:
      # the presentation wrapper, the screensaver, and omarchy-launch-tui.
      xdg-terminal-exec
      # pactl, for the seven omarchy-audio-* scripts behind the bar's output
      # and input device pickers. Supplied by the pulseaudio package even
      # though the sound server here is pipewire-pulse.
      pulseaudio
      # Types the selection for the emoji picker and the clipboard paste
      # actions, which have no other way back into the focused window.
      wtype
      # gsettings, for omarchy-theme-set-gnome and omarchy-display-text-size.
      glib
      # update-desktop-database, run after adding or removing a web app or a
      # TUI launcher entry.
      desktop-file-utils
      # External-monitor brightness behind the bar's omarchy.monitor widget.
      ddcutil
      # xkbcli, read by the bar's keyboard-layout widget.
      libxkbcommon
    ];

    meta = {
      description = "Omarchy 4 quickshell desktop adapted for NixOS";
      homepage = "https://github.com/omacom/omarchy";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  }
