{
  config,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    host = "127.0.0.1";
    port = 11434;
  };
  #services.open-webui.enable = true;
  home.packages = with pkgs; [
    lmstudio
    #ollama
    open-webui
    llm
    gorilla-cli
  ];
}
