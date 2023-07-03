{ config, lib, pkgs, stdenv, ... }:
{
  programs = {
   oh-my-posh = {
     enable = true;
     enableFishIntegration = true;
     settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile "./omp.config.json"));
    };
  };
}

