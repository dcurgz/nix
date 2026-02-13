{
  config,
  lib,
  pkgs,
  inputs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT NIXOS_PRESETS;

  hostname = "vm-openwebui";
  dataDir = "/data/open-webui";
  certsDir = "/data/open-webui.certs";
  ollamaDir = "/data/open-webui.ollama";

  internal_port = 8901;

  by = config.by.constants;
  secrets = config.by.secrets;
in
{
  age.secrets.tailscale-auth-key = {
    file = "${FLAKE_ROOT}/secrets/tailscale/guests/vm-openwebui.age"; 
    mode = "0440"; 
    group = "kvm";
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir} 770 root data -"
    "d ${certsDir} 770 root data -"
    "d ${ollamaDir} 770 root data -"
  ];

  hyperberry.virtualization = {
    vms.${hostname} = {
      enable = true;
      vcpus = 2;
      memory = 1024 * 8 + 1;

      credentialFiles = {
        tailscale-auth-key = config.age.secrets.tailscale-auth-key.path;
      };
  
      networking = {
        macAddress = "02:00:00:00:00:09";
        ipAddress = "10.0.0.19";
      };

      nixpkgsConfig = {
        config.allowUnfree = true;
        config.nvidia.acceptLicense = true;
      };

      mounts = [
        {
          source = dataDir;
          mountPoint = "/var/lib/open-webui";
          tag = "openwebui-data";
          proto = "virtiofs";
          socket = "openwebui-data.sock";
        }
        {
          source = certsDir;
          mountPoint = "/etc/ssl/certs";
          tag = "openwebui-certs";
          proto = "virtiofs";
          socket = "openwebui-certs.sock";
        }
        {
          source = ollamaDir;
          mountPoint = "/var/lib/private/ollama";
          tag = "openwebui-ollama";
          proto = "virtiofs";
          socket = "openwebui-ollama.sock";
        }
      ];

      devices = [
        {
          bus = "pci";
          path = by.hardware.pcie.nvidia_gpu;
        }
        {
          bus = "pci";
          path = by.hardware.pcie.nvidia_audio;
        }
      ];

      # VM-specific configuration
      config =
        let
          nvidia = config.boot.kernelPackages.nvidiaPackages.stable;
        in
        {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            # define media, data groups
            "${NIXOS_PRESETS}/security/groups"
          ];

          nix.channel.enable = false;

          services.open-webui = {
            enable = true;
            host = "0.0.0.0";
            port = internal_port;
          };  

          systemd.services.open-webui.serviceConfig = {
            DynamicUser = lib.mkForce false;
            User = "open-webui";
          };

          users.users.open-webui = {
            isSystemUser = true;
            group = "open-webui";
            extraGroups = [ "data" ];
          };
          users.groups.open-webui = {};

 
         services.nginx = 
            let
              address = "vm-openwebui.${secrets.tailscale.magic_dns}";
            in
            {
              enable = true;
              recommendedGzipSettings = true;
              recommendedOptimisation = true;
              recommendedProxySettings = true;
              recommendedTlsSettings = true;
              virtualHosts."${address}" = {
                default = true;
                forceSSL = true;
                sslCertificate = "/etc/ssl/certs/${address}.crt";
                sslCertificateKey = "/etc/ssl/certs/${address}.key";
                locations."/" = {
                  proxyPass = "http://localhost:${toString internal_port}";
                  proxyWebsockets = true;

                  extraConfig = ''
                    client_max_body_size 16G;
                  '';
                };
              };
            };
          # give access to certs
          users.users.nginx.extraGroups = [ "data" ];

          boot = {
            kernelModules = [
              "nvidia"
              "nvidia_modeset"
              "nvidia_drm"
              "nvidia_uvm"
            ];

            kernelParams = [
              "nvidia-drm.modeset=1"
              "nvidia-drm.fbdev=1"
            ];
          };

          services.xserver.videoDrivers = [ "nvidia" ];

          hardware.graphics = {
            enable = true;
            extraPackages = with pkgs; [
              #libva
              #libva-utils
              #libva-vdpau-driver
              #libvdpau
              #libvdpau-va-gl
              #nvidia-vaapi-driver
              #vdpauinfo
            ];
          };

          hardware.nvidia = {
            #forceFullCompositionPipeline = true;
            modesetting.enable = true;
            powerManagement.enable = true;
            open = true;
            nvidiaSettings = false;
            nvidiaPersistenced = true;
            package = nvidia;
          };

          services = {
            ollama = {
              enable = true;
              user = "ollama";
              group = "ollama";

              package = pkgs.ollama-cuda;

              host = "0.0.0.0";
              port = 11434;

              loadModels = [
                "dolphin3"
                "gemma3:27b-it-qat"
                "glm-4.7-flash:latest"
                "deepseek-r1:32b"
              ];

              environmentVariables = {
                OLLAMA_FLASH_ATTENTION = "true";
                OLLAMA_CONTEXT_LENGTH = "32768";
  # OLLAMA_CONTEXT_LENGTH = "16384";
                OLLAMA_KV_CACHE_TYPE = "q8_0";
                OLLAMA_KEEP_ALIVE = "10m";
                OLLAMA_MAX_LOADED_MODELS = "4";
                OLLAMA_MAX_QUEUE = "64";
                OLLAMA_NUM_PARALLEL = "1";
                OLLAMA_ORIGINS = "*";
              };
            };
          };

         # systemd.services.ollama.serviceConfig = {
         #   DeviceAllow = lib.mkForce [ ];
         #   DevicePolicy = lib.mkForce "auto";
         # };

         # users.users.ollama = {
         #   isSystemUser = true;
         #   group = "ollama";
         # };
         # users.groups.ollama = {};

          systemd.services.nvidia-gpu-config = {
            description = "Configure NVIDIA GPU";
            wantedBy = [ "multi-user.target" ];
            path = [ nvidia.bin ];
            # just running `nvidia-smi` seems to be enough to initialize the GPU,
            # before this must be done before ollama starts.
            script = "nvidia-smi";
            serviceConfig.Type = "oneshot";
          };

          systemd.services.ollama.after = [ "nvidia-gpu-config.service" ];

          networking.firewall.allowedTCPPorts = [
            22
            80
            443
          ];

          services.tailscale.authKeyFile = "/run/credentials/tailscaled.service/tailscale-auth-key";

          systemd.services.tailscaled = {
            serviceConfig = {
              LoadCredential = [ "tailscale-auth-key" ];
            };
          };
      };
    };
  };
}
