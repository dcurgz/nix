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

  hostname = "vm-mc-leedlemon";
  nix-minecraft = inputs.nix-minecraft;

  dataDir = "/data/minecraft-leedlemon";
  version = "v2";

  inherit (pkgs.by.lib) replaceOptionalVars;
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:12";
        ipAddress = "10.0.0.22";
      };
      microvm = {
        config = { config, ... }: {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            "${NIXOS_PRESETS}/security/groups"
            inputs.neoforge-1-21-1.nixosModules.x86_64-linux.default
            inputs.agenix.nixosModules.default
          ];

          microvm.vcpu = 6;
          microvm.mem = 1024 * 16;
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

          services.nginx =
            let
              domain = secrets.hosts.${hostname}.ssh.hostname;
              bluemap_http = 8100;
            in
            {
              enable = true;
              recommendedProxySettings = true;
              recommendedGzipSettings = true;
              recommendedOptimisation = true;
              recommendedTlsSettings = true;
              virtualHosts."${domain}" = {
                default = true;
                forceSSL = true;
                sslCertificate = "/etc/ssl/certs/${domain}.crt";
                sslCertificateKey = "/etc/ssl/certs/${domain}.key";
                locations."/" = {
                  proxyPass = "http://localhost:${toString bluemap_http}";
                  proxyWebsockets = true;
                };
              };
            };

          users.users.minecraft.extraGroups = [ "data" ];
          users.users.nginx.extraGroups     = [ "data" ];
        };
      };
    };
  };
}
