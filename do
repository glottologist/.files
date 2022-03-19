#! /usr/bin/env bash
set +x

WORKFLOW=$1
SERVER=$2
USER=$3
ADDITIONAL_ARGS=$5

usage(){

      echo "======================================================================"
      echo "./do <workflow> <servername> <user> <build-type>"
      echo "=> where:"
      echo "=> workflow = build or apply.  'build' solely builds derivations whereas apply will build the derivation and apply that to the current host system"
      echo "=> servername = server / machine alias"
      echo "=> user = user name"
      echo "=> build-type = home or system"
}

if [ -z "$WORKFLOW" ]
then
      echo "No workflow entered"
      usage
      exit 1;
fi

if [ -z "$SERVER" ]
then
      echo "No server name entered"
      usage
      exit 1;
fi

if [ -z "$USER" ]
then
      echo "No user name entered"
      usage
      exit 1;
fi

if [ -z "$4" ]
then
  BUILD="all"
else
  BUILD=$4
fi


home(){
  export NIXPKGS_ALLOW_INSECURE=1
  nix build ".#homeConfigurations.${USER}.activationPackage" $ADDITIONAL_ARGS --impure

  if [ "$WORKFLOW" = "apply" ]; then
    echo "$MARKER"
    echo "Applying home configuration"
    result/activate
    echo "$MARKER"
    echo "Applying post home"
    copy_home_files
    echo "$MARKER"
  fi
}

system(){
 export NIXPKGS_ALLOW_INSECURE=1
 nix build ".#nixosConfigurations.${SERVER}.config.system.build.toplevel" $ADDITIONAL_ARGS --impure

  if [ "$WORKFLOW" = "apply" ]; then
    echo "$MARKER"
    echo "Applying nixos configuration"
    sudo nixos-rebuild switch --flake
    echo "$MARKER"
  fi
}

all(){
  system
  home
}


echo "$MARKER"
echo "Doing the following configuration:"
echo "WORKFLOW => $WORKFLOW"
echo "SERVER => $SERVER"
echo "USER => $USER"
echo "BUILD => $BUILD"
echo "$MARKER"

make_dir_and_copy() {
  echo "Copying $1"
  mkdir -p $HOME/$1
  cp -rf "homes/${USER}/$1" "$HOME/$1"
}

copy_home_files() {
   make_dir_and_copy "Pictures"
   make_dir_and_copy "icons"
}
case $BUILD in
  "home")
    home;;
  "system")
    system;;
  "all")
    all;;
esac

exit 0
