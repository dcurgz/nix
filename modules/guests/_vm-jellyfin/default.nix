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

  hostname = "vm-jellyfin";
  jellyfin_library = "/media/content";
  jellyfin_data = "/data/jellyfin-data";
  jellyfin_cache = "/data/jellyfin-cache";
  jellyfin_http = 8096;
in
{

  systemd.tmpfiles.rules = [
    "d ${jellyfin_data} root data"
    "d ${jellyfin_cache} root data"
  ];

  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:08";
        ipAddress = "10.0.0.18";
      };
      
      microvm = {
        extraModules = [
          inputs.agenix.nixosModules.default
        ];
        config = { config, ... }: {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            "${NIXOS_PRESETS}/security/groups"
          ];

          microvm.vcpu = 4;
          microvm.mem = 1024 * 6 + 1;
          microvm.shares = [
            # jellyfin media library 
            {
              source = jellyfin_library;
              mountPoint = jellyfin_library;
              tag = "jellyfin-library";
              proto = "virtiofs";
              socket = "jellyfin-library.sock";
            }
            # jellyfin data directory
            {
              source = jellyfin_data;
              mountPoint = jellyfin_data;
              tag = "jellyfin-data";
              proto = "virtiofs";
              socket = "jellyfin-data.sock";
            }
            # jellyfin cache directory
            {
              source = jellyfin_cache;
              mountPoint = "/var/cache/jellyfin";
              tag = "jellyfin-cache";
              proto = "virtiofs";
              socket = "jellyfin-cache.sock";
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

          nix.channel.enable = false;

          systemd.tmpfiles.rules = [
            "Z /etc/ssl/certs 550 root data"
          ];

          services.jellyfin = {
            enable = true;
            dataDir = jellyfin_data;
          };

          users.users.jellyfin.extraGroups = [ "media" "data" ];

          # Nginx reverse proxy with SSL
          services.nginx =
            let
              address = secrets.hosts.vm-jellyfin.ssh.hostname;
            in
            {
              enable = true;
              recommendedProxySettings = true;
              recommendedGzipSettings = true;
              recommendedOptimisation = true;
              recommendedTlsSettings = true;
              virtualHosts."${address}" = {
                default = true;
                forceSSL = false;
                addSSL = true;
                sslCertificate = "/etc/ssl/certs/${address}.crt";
                sslCertificateKey = "/etc/ssl/certs/${address}.key";
                locations."/" = {
                  proxyPass = "http://localhost:${toString jellyfin_http}";
                  proxyWebsockets = true;
                };
              };
            };

          users.users.nginx.extraGroups = [ "data" ]; # for certs

          networking.firewall.allowedTCPPorts = [
            22
            80
            443
          ];

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
