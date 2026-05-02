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
  inherit (globals) FLAKE_ROOT NIXOS_PRESETS;

  hostname = "vm-mc-slime-1";
  nix-minecraft = inputs.nix-minecraft;

  dataDir = "/data/minecraft-slime_staging";
  version = "v5";

  inherit (pkgs.by.lib) replaceOptionalVars;
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:07";
        ipAddress = "10.0.0.17";
      };
      microvm = {
        extraModules = [
          inputs.agenix.nixosModules.default
          inputs.neoforge-1-21-1.nixosModules.x86_64-linux.default
        ];
        config = { config, ... }: {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            "${NIXOS_PRESETS}/security/groups"
          ];

          microvm.vcpu = 6;
          microvm.mem = 1024 * 12;
          microvm.shares = [
            {
              source = dataDir;
              mountPoint = dataDir;
              tag = "minecraft-data";
              proto = "virtiofs";
            }
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

          age.secrets.tailscale-auth-key = {
            file = "${FLAKE_ROOT}/secrets/tailscale/guests/${hostname}.age"; 
            mode = "0440"; 
          };
          services.tailscale.authKeyFile = config.age.secrets.tailscale-auth-key.path;
        };
      };
    };
  };
}
