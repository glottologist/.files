{
  config,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    # Optional: load models on startup
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
