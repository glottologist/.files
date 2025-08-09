{
  config,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    loadModels = ["deepcoder:14b" "gemma3:27b" "qwen3:8b"];
    acceleration = "rocm";
    host = "127.0.0.1";
    port = 11434;
  };
  systemd.services.ollama.serviceConfig = {
    Environment = ["OLLAMA_HOST=0.0.0.0:11434"];
  };

  services.open-webui = {
    enable = true;
    port = 8888;
    host = "127.0.0.1";
    package = pkgs.open-webui; # pkgs must be from stable, for example nixos-24.11
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
  };
}
