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
  home.packages = with pkgs; [
    ollama
    lmstudio
  ];
}
