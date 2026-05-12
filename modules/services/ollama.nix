{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.ollama = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    let
      ollamaDir = "/data/open-webui.ollama";
      pkgs-ollama = (import inputs.nixpkgs-ollama {
        inherit (pkgs) system;
        config.allowUnfree = true;
      });
    in
    {
      systemd.tmpfiles.rules = [
        "d ${ollamaDir} 770 root data -"
      ];

      services.ollama = {
        enable = true;
        user = "ollama";
        group = "ollama";

        home = ollamaDir;
        package = pkgs-ollama.ollama-cuda;

        host = "0.0.0.0"; 
        port = 11434;

        loadModels = [
          "gemma3:27b-it-qat"
          "gemma4:26b" 
          "gemma4:31b"
          "glm-4.7-flash:latest"
          "qwen3.5:27b"
          "qwen3.6:35b"
        ];

        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "true";
          OLLAMA_CONTEXT_LENGTH = "32768";
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          OLLAMA_KEEP_ALIVE = "10m";
          OLLAMA_MAX_LOADED_MODELS = "4";
          OLLAMA_MAX_QUEUE = "64";
          OLLAMA_NUM_PARALLEL = "1";
          OLLAMA_ORIGINS = "*";
        };
      };

      users.users.ollama = {
        isSystemUser = true;
        group = "ollama";
        extraGroups = [ "data" ];
      };
      users.groups.ollama = {};
    });
}
