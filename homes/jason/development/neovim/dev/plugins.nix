{ buildVimPlugin, buildVimPluginFrom2Nix, fetchFromGitHub }:
{
 nvim-metals = buildVimPluginFrom2Nix {
    name = "nvim-metals";
    src  = fetchFromGitHub {
      owner  = "scalameta";
      repo   = "nvim-metals";
      rev    = "69a5cf9380defde5be675bd5450e087d59314855";
      sha256 = "1kjr7kgwvg1c4gglipmasvpyrk4gar4yi9kd8xdfqyka9557vyy9";
    };
  };

  completion-nvim = buildVimPlugin {
    name = "completion-nvim";
    src  = fetchFromGitHub {
      owner  = "nvim-lua";
      repo   = "completion-nvim";
      rev    = "6d7c66e76ffce6ad06d82cf1842274bddff8b829";
      sha256 = "1sajay0ki9nnx9y8f6igzmsyi72wydi9fb0xzi9qr0p0xck98k34";
    };
  };

  diagnostic-nvim = buildVimPlugin {
    name = "diagnostic-nvim";
    src  = fetchFromGitHub {
      owner  = "nvim-lua";
      repo   = "diagnostic-nvim";
      rev    = "d7734f12f2c980b08c205583b7756d735222fb9f";
      sha256 = "1fsya1midzyd46x0y69v2xi0p91yg2cm4vhw36ai99kjbha005pz";
    };
  };
}
