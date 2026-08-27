{pkgs}:
pkgs.writeShellScriptBin "unified-clipboard" (builtins.readFile ./unified-clipboard.sh)
