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
  wireplumber,
  quickshell,
  udiskie,
  qrencode,
  hyprsunset,
}: let
  # Scripts whose job is pacman/yay package management; each becomes a
  # stub that raises a notification instead of failing silently.
  archOnly = [
    "omarchy-channel-current"
    "omarchy-channel-set"
    "omarchy-debug"
    "omarchy-dev-pkg-test"
    "omarchy-install-gaming-retroarch"
    "omarchy-migrate"
    "omarchy-pkg-add"
    "omarchy-pkg-aur-add"
    "omarchy-pkg-aur-install"
    "omarchy-pkg-drop"
    "omarchy-pkg-install"
    "omarchy-pkg-missing"
    "omarchy-pkg-present"
    "omarchy-pkg-remove"
    "omarchy-provision-first-run"
    "omarchy-provision-owner"
    "omarchy-refresh-pacman"
    "omarchy-reinstall-pkgs"
    "omarchy-remove-launcher-entry"
    "omarchy-setup-security-fingerprint"
    "omarchy-update-aur-pkgs"
    "omarchy-update-available"
    "omarchy-update-keyring"
    "omarchy-update-orphan-pkgs"
    "omarchy-update-pacman-guard"
    "omarchy-update-pkg-prune"
    "omarchy-update-restart"
    "omarchy-update-system-pkgs"
    "omarchy-update-system-pkgs-when-conflicted"
    "omarchy-upgrade-to-quattro"
    "omarchy-upload-log"
    "omarchy-version-channel"
    "omarchy-version-pkgs"
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

      for script in ${lib.concatStringsSep " " archOnly}; do
        cat > "$out/bin/$script" <<'EOF'
      #!/bin/bash
      notify-send -u normal "Omarchy on NixOS" \
        "$(basename "$0") manages Arch packages and is unavailable here. Use the flake instead." 2>/dev/null || true
      echo "$(basename "$0"): unavailable on NixOS (Arch package management)" >&2
      exit 0
      EOF
        chmod +x "$out/bin/$script"
      done

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
      wireplumber
      quickshell
      udiskie
      qrencode
      hyprsunset
    ];

    meta = {
      description = "Omarchy 4 quickshell desktop adapted for NixOS";
      homepage = "https://github.com/omacom/omarchy";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  }
