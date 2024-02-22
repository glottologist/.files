{ pkgs }:

pkgs.neovim-unwrapped.overrideAttrs (
  old: {
    name    = "neovim-6.0.1";
    version = "v0.6.1";

    src = pkgs.fetchFromGitHub {
      owner  = "neovim";
      repo   = "neovim";
      rev    = "5b839ced692230fe582fde41f79f875ee90451e8";
      sha256 = "0lgbf90sbachdag1zm9pmnlbn35964l3khs27qy4462qzpqyi9fi";
    };

    buildInputs = old.buildInputs ++ [ pkgs.tree-sitter ];
  }
)
