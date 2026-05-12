{
  inputs,
  lib,
  globals,
  prebuiltPackages,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-mc-leedlemon";
  dataDir = "/data/minecraft-leedlemon";
  version = "v4";
in
{
  flake.modules.nixos.${hostName} = flake.lib.mkMicroVM
    rec {
      enable = true;
      inherit hostName;
      system = "x86_64-linux";
      pkgs = prebuiltPackages.${system};
      extraModules = [
        inputs.neoforge-1-21-1.nixosModules.${system}.default
        ### 3rd party modules
        inputs.agenix.nixosModules.default
      ];
      microvmConfig = {
        networking = {
          macAddress = "02:00:00:00:00:12";
          ipAddress = "10.0.0.22";
        };
        tailscale = {
          enable = true;
          autologin = true;
        };
      };
      tags = with flake.tags; [ ];
    }

    ({
      config,
      pkgs,
      ...
    }:

    let
      secrets = config.by.git-secrets;
      inherit (pkgs.by.lib) replaceOptionalVars;
    in
    {
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

      environment.systemPackages = with pkgs; [
        jre_headless
        rcon-cli
      ];

      minecraft.neoforge = {
        enable = true;
        package = builtins.break pkgs.by.neoforge-1-21-1;
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
          domain = secrets.hosts.${hostName}.ssh.hostName;
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
    });
}
