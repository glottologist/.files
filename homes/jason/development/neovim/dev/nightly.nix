{ pkgs }:

pkgs.neovim-unwrapped.overrideAttrs (
  old: {
    name    = "neovim-5.0.1";
    version = "v0.5.1";

    src = pkgs.fetchFromGitHub {
      owner  = "neovim";
      repo   = "neovim";
      rev    = "0159e4daaed1347db8719c27946fcfdc4e49e92d";
      sha256 = "0lgbf90sbachdag1zm9pmnlbn35964l3khs27qy4462qzpqyi9fi";
    };

    buildInputs = old.buildInputs ++ [ pkgs.tree-sitter ];
  }
)
