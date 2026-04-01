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
  secrets = config.by.secrets;
  inherit (globals) FLAKE_ROOT NIXOS_PRESETS;

  hostname = "vm-mc-leedl-sta";
  nix-minecraft = inputs.nix-minecraft;

  dataDir = "/data/minecraft-leedlemon_staging";
  version = "v5-staging";

  inherit (pkgs.by.lib) replaceOptionalVars;
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:13";
        ipAddress = "10.0.0.23";
      };
      microvm = {
        config = { config, ... }: {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            "${NIXOS_PRESETS}/security/groups"
            inputs.neoforge-1-21-1.nixosModules.x86_64-linux.default
            inputs.agenix.nixosModules.default
          ];

          microvm.vcpu = 3;
          microvm.mem = 1024 * 6;
          microvm.shares = [
            {
              source = dataDir;
              mountPoint = dataDir;
              tag = "minecraft-data";
              proto = "virtiofs";
            }
            # SSL certificates
            {
              source = "/etc/ssl/certs";
              mountPoint = "/etc/ssl/certs";
              tag = "ssl-certs";
              proto = "virtiofs";
              socket = "ssl-certs.sock";
            }
          ];

          networking.firewall.allowedTCPPorts = [ 25565 ];
          networking.firewall.allowedUDPPorts = [ 25565 ];

          age.secrets.tailscale-auth-key = {
            file = "${FLAKE_ROOT}/secrets/tailscale/guests/${hostname}.age"; 
            mode = "0440"; 
          };
          services.tailscale.authKeyFile = config.age.secrets.tailscale-auth-key.path;

          environment.systemPackages = with pkgs; [
            jre_headless
            rcon-cli
          ];

          minecraft.neoforge = {
            enable = true;
            package = pkgs.by.neoforge-1-21-1;
            overlays = {
              modpack = pkgs.by.modpack-leedlemon."${version}";
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

          # Ensure that tailscaled is not terminated before the server shuts down.
          systemd.services.neoforge-server = {
            after = [ "tailscaled.service" ];
            serviceConfig = {
              Requires = [ "tailscaled.service" ];
            };
          };

          users.users.minecraft.extraGroups = [ "data" ];
        };
      };
    };
  };
}
