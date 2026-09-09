#! /usr/bin/env bash
set -euo pipefail

LAYER=${1:-}
WORKFLOW=${2:-}
SPECIFIER=${3:-}
ENABLE_HYPRLAND_0=${4:-0}
MARKER=${MARKER:-}

usage() {

    echo "======================================================================"
    echo "./do <layer> <workflow> <user/host>"
    echo "=> where:"
    echo "=> layer = host or home.  'host' applies a nixos configuration with a specified hostname.  'home' applies a home configuration with a given user name"
    echo "=> workflow = build or apply.  'build' solely builds derivations whereas apply will build the derivation and apply that to the current host system"
    echo "=> user/host = user name if applying home configuration or host name if applying nixos configuration"
}

if [ -z "$LAYER" ]; then
    echo "No layer entered, please specifiy host or home"
    usage
    exit 1
fi
if [ -z "$WORKFLOW" ]; then
    echo "No workflow entered, please specifiy build or apply"
    usage
    exit 1
fi

if [ -z "$SPECIFIER" ]; then
    echo "Please enter username (if applying home) or host name (if applying nixos)"
    usage
    exit 1
fi

echo_nix_version() {
    nix --version
}

home() {
    export NIXPKGS_ALLOW_INSECURE=1
    export NIXPKGS_ALLOW_UNFREE=1
    nix build ".#homeConfigurations.${SPECIFIER}.activationPackage" --impure

    if [ "$WORKFLOW" = "apply" ]; then
        echo "$MARKER"
        echo "Applying home configuration"
        # Standalone activate refuses to clobber unmanaged files unless
        # this is set; the old file is renamed to *.$HOME_MANAGER_BACKUP_EXT.
        HOME_MANAGER_BACKUP_EXT=bak result/activate
        echo "$MARKER"
    fi
}

host() {
    export NIXPKGS_ALLOW_INSECURE=1
    export NIXPKGS_ALLOW_UNFREE=1
    export ENABLE_HYPRLAND=$ENABLE_HYPRLAND_0
    nix build ".#nixosConfigurations.${SPECIFIER}.config.system.build.toplevel" --impure

    if [ "$WORKFLOW" = "apply" ]; then
        echo "$MARKER"
        echo "Applying nixos configuration"
        # Activate the toplevel just built above rather than
        # `nixos-rebuild switch`. The latter re-evaluates the whole flake as
        # root, whose eval cache is cold; on a memory-constrained guest that
        # second evaluation exhausts RAM and the evaluator dies with SIGSEGV.
        # Setting the system profile and running switch-to-configuration
        # reuses the existing build and performs no evaluation.
        sudo nix-env -p /nix/var/nix/profiles/system --set ./result
        sudo ./result/bin/switch-to-configuration switch
        echo "$MARKER"
    fi
}

echo_nix_version

echo "$LAYER requested"
case $LAYER in
"home")
    home
    ;;
"host")
    host
    ;;
*)
    usage
    ;;
esac

exit 0
