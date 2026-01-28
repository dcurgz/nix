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
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      enable = true;

      vcpus = 6;
      memory = 1024 * 12;

      networking = {
        macAddress = "02:00:00:00:00:06";
        ipAddress = "10.0.0.16";
      };

      # Additional tmpfiles for minecraft data directory
      tmpfiles = [
        "d ${dataDir} 0755 root root"
      ];

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
          #inputs.nix-minecraft.nixosModules.minecraft-servers
          inputs.neoforge-server.nixosModules.x86_64-linux.default
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
          package = pkgs.local.neoforge-1-21-1;
          overlays = {
            modpack = pkgs.local.modpack-slime;
            config = pkgs.linkFarm "config-overlay" [
              {
                name = "server.properties";
                path = ./server.properties;
              }
            ];
          };
          dataDir = dataDir;
        };
      };
    };
  };
}
