#! /usr/bin/env bash
#set +x

LAYER=$1
WORKFLOW=$2
SPECIFIER=$3
ENABLE_HYPRLAND_0=${4:-0}

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

update_flake() {
    nix flake update
}

register_nixos_unstable_channel() {
    nix-channel --add https://nixos.org/channels/nixos-unstable nixos
}

home() {
    export NIXPKGS_ALLOW_INSECURE=1
    export NIXPKGS_ALLOW_UNFREE=1
    nix build ".#homeConfigurations.${SPECIFIER}.activationPackage" --impure

    if [ "$WORKFLOW" = "apply" ]; then
        echo "$MARKER"
        echo "Applying home configuration"
        result/activate
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
        sudo nixos-rebuild switch --impure --flake .
        echo "$MARKER"
    fi
}

echo_nix_version

register_nixos_unstable_channel

update_flake

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
