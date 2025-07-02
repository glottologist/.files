{
  config,
  pkgs,
  ...
}: {


  home.packages = with pkgs; [
    lmstudio
    llm
    gorilla-cli
  ];
}
