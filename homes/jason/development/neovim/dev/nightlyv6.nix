{ pkgs }:

pkgs.neovim-unwrapped.overrideAttrs (
  old: {
    name    = "neovim-nightly-2021-09-01";
    version = "v0.6.0-dev+210-g6751d6254";

    src = pkgs.fetchFromGitHub {
      owner  = "neovim";
      repo   = "neovim";
      rev    = "6751d6254b35d216a86817cd414d5d06e3ff641d";
      sha256 = "196x6n611bx0wr5dz21cwkaxn87n6w1ll44j3p0n9jcn95sw13k9";
    };

    buildInputs = old.buildInputs ++ [ pkgs.tree-sitter ];
  }
)
