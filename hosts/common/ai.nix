 

{
  config,
  pkgs,
  ...
}: {

   services.ollama = {
    enable = true;
    loadModels = [ "llama3.2:3b"  ];
    acceleration = "rocm";
    host = "127.0.0.1";
    port = 11434;
  };



  services.open-webui = {
    enable = true;
    port = 8888;
    host = "127.0.0.1";
  };

}

