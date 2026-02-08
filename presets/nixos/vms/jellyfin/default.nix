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

  hostname = "vm-jellyfin";
  jellyfin_library = "/media/content";
  jellyfin_data = "/data/jellyfin-data";
  jellyfin_http = 8096;
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      enable = true;

      vcpus = 4;
      memory = 1024 * 6 + 1;

      networking = {
        macAddress = "02:00:00:00:00:08";
        ipAddress = "10.0.0.18";
      };

      # Additional shares beyond the common ones
      mounts = [
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
        # SSL certificates
        {
          source = "/etc/ssl/certs";
          mountPoint = "/etc/ssl/certs";
          tag = "ssl-certs";
          proto = "virtiofs";
          socket = "ssl-certs.sock";
        }
      ];

      # VM-specific configuration
      config = {
        imports = [
          "${NIXOS_PRESETS}/packages/core"
          "${NIXOS_PRESETS}/security/groups"
        ];

        nix.channel.enable = false;

        services.jellyfin = {
          enable = true;
          dataDir = jellyfin_data;
        };

        users.users.jellyfin.extraGroups = [ "media" "data" ];

        # Nginx reverse proxy with SSL
        services.nginx = {
          enable = true;
          virtualHosts."jellyfin" = {
            default = true;
            forceSSL = false;
            sslCertificate = "/etc/ssl/certs/selfsigned.crt";
            sslCertificateKey = "/etc/ssl/certs/selfsigned.key";
            locations."/" = {
              proxyPass = "http://localhost:${toString jellyfin_http}";
              proxyWebsockets = true;

              extraConfig = ''
                client_max_body_size 16G;
              '';
            };
          };
        };

        networking.firewall.allowedTCPPorts = [
          22
          80
          443
        ];
      };
    };
  };
}
