#! /usr/bin/env bash
set +x

WORKFLOW=$1
USER=$2
ADDITIONAL_ARGS=$3

usage(){

      echo "======================================================================"
      echo "./do <workflow> <user>"
      echo "=> where:"
      echo "=> workflow = build or apply.  'build' solely builds derivations whereas apply will build the derivation and apply that to the current host system"
      echo "=> user = user name"
}

if [ -z "$WORKFLOW" ]
then
      echo "No workflow entered"
      usage
      exit 1;
fi

if [ -z "$USER" ]
then
      echo "No user name entered"
      usage
      exit 1;
fi

echo_nix_version(){
  echo $(nix --version)
}





register_nixos_unstable_channel() {
  nix-channel --add https://nixos.org/channels/nixos-unstable nixos
}

echo_nix_version

register_nixos_unstable_channel

echo "$MARKER"
echo "Doing the following configuration:"
echo "WORKFLOW => $WORKFLOW"
echo "USER => $USER"
echo "$MARKER"

  export NIXPKGS_ALLOW_INSECURE=1
  nix build ".#homeConfigurations.${USER}.activationPackage" --impure $ADDITIONAL_ARGS

  if [ "$WORKFLOW" = "apply" ]; then
    echo "$MARKER"
    echo "Applying home configuration"
    result/activate
    echo "$MARKER"
  fi

exit 0
