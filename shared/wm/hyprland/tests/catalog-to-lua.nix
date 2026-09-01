# Nix guideline compliant 2026-09-01
{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  serializer = import ../catalog-to-lua.nix { inherit lib; };
  fixture = {
    bind = [
      {
        binding = ''SUPER,K,exec,printf "a,b ]=] c"'';
        group = "Utilities";
        description = "Keybindings [==[ safe";
      }
    ];
    bindm = [
      {
        binding = "SUPER,mouse:272,movewindow";
        group = "Windows";
        description = "Move window";
      }
    ];
  };
  module = pkgs.writeText "catalog.lua" (serializer fixture);
in
pkgs.runCommand "catalog-to-lua-test" { nativeBuildInputs = [ pkgs.lua ]; } ''
  lua - ${module} <<'LUA'
  local catalog = dofile(arg[1])
  assert(#catalog.bind == 1)
  assert(#catalog.bindm == 1)
  assert(catalog.bind[1].binding == 'SUPER,K,exec,printf "a,b ]=] c"')
  assert(catalog.bind[1].group == "Utilities")
  assert(catalog.bind[1].description == "Keybindings [==[ safe")
  assert(catalog.bindm[1].binding == "SUPER,mouse:272,movewindow")
  assert(catalog.bindm[1].group == "Windows")
  assert(catalog.bindm[1].description == "Move window")
  LUA
  touch $out
''
