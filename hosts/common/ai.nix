{
  config,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    loadModels = [
      "minimax-m2.7:cloud"
      "nemotron-3-super"
      "qwen3.5"
      "qwen3.6"
      "qwen3-coder-next"
    ];
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
      OPENAI_API_BASE_URLS = "http://127.0.0.1:8000/v1";
      OPENAI_API_KEYS = "vllm-local";
    };
  };

  # CPU build from nixpkgs (VLLM_TARGET_DEVICE=cpu); ROCm on Strix Point is
  # not yet supported and would need a torch-rocm overlay + gfx115x targets.
  systemd.services.vllm = {
    description = "vLLM OpenAI-compatible server (CPU)";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "vllm";
      Environment = "HF_HOME=/var/lib/vllm";
      ExecStart = "${pkgs.vllm}/bin/vllm serve Qwen/Qwen2.5-0.5B-Instruct --host 127.0.0.1 --port 8000 --served-model-name qwen2.5-0.5b --enforce-eager";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
