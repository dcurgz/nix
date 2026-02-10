{
  config,
  lib,
  pkgs,
  inputs,
  globals,
  ...
}:

let
  by = config.by.constants;
  inherit (globals) NIXOS_PRESETS;

  hostname = "vm-mc-slime";
  nix-minecraft = inputs.nix-minecraft;

  dataDir = "/data/minecraft-slime";
  version = "v5";

  inherit (pkgs.by.lib) replaceOptionalVars;
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      enable = true;

      vcpus = 6;
      memory = 1024 * 16;

      networking = {
        macAddress = "02:00:00:00:00:06";
        ipAddress = "10.0.0.16";
      };

      # Additional shares beyond the common ones
      mounts = [
        {
          source = dataDir;
          mountPoint = dataDir;
          tag = "minecraft-data";
          proto = "virtiofs";
        }
      ];

      # VM-specific configuration
      config = {
        imports = [
          inputs.neoforge-1-21-1.nixosModules.x86_64-linux.default
          "${NIXOS_PRESETS}/packages/core"
        ];

        networking.firewall.allowedTCPPorts = [ 25565 ];
        networking.firewall.allowedUDPPorts = [ 25565 ];

        environment.systemPackages = with pkgs; [
          jre_headless
          rcon-cli
        ];

        minecraft.neoforge = {
          enable = true;
          package = pkgs.by.neoforge-1-21-1;
          overlays = {
            modpack = pkgs.by.modpack-slime."${version}";
            config = pkgs.linkFarm "config-overlay" [
              {
                name = "server.properties";
                path = replaceOptionalVars ./server.properties {
                  inherit version;
                }; 
              }
            ];
          };
          dataDir = dataDir;
        };

        users.users.minecraft.extraGroups = [ "data" ];
      };
    };
  };
}
