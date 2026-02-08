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

  hostname = "vm-immich";
  immich_port = 8903;
  immich_media = "/data/immich";
  immich_db = "/data/immich-db";
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      enable = true;

      vcpus = 4;
      memory = 1024 * 8 + 1;

      networking = {
        macAddress = "02:00:00:00:00:02";
        ipAddress = "10.0.0.12";
      };

      # Allow unfree packages for this VM
      nixpkgsConfig = {
        config.allowUnfree = true;
      };

      # Additional shares beyond the common ones
      mounts = [
        # Immich media storage
        {
          source = immich_media;
          mountPoint = "/var/lib/immich";
          tag = "immich-media";
          proto = "virtiofs";
          socket = "immich-media.sock";
        }
        # PostgreSQL database storage
        {
          source = immich_db;
          mountPoint = "/var/lib/postgresql";
          tag = "immich-db";
          proto = "virtiofs";
          socket = "immich-db.sock";
        }
        # Photos directory (read-only)
        {
          source = "/media/photos";
          mountPoint = "/media/photos";
          tag = "photos";
          proto = "virtiofs";
          socket = "photos.sock";
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
          # define media, data groups
          "${NIXOS_PRESETS}/security/groups"
        ];

        nix.channel.enable = false;

        # Immich-specific packages
        environment.systemPackages = with pkgs; [
          immich-cli
        ];

        # Immich service configuration
        services.immich = {
          enable = true;
          openFirewall = true;
          host = "0.0.0.0";
          port = immich_port;
          database = {
            enable = true;
            createDB = true;
            # Disable pgvecto.rs vectors (smart search) - not compatible with older PostgreSQL
            enableVectors = false;
          };
        };

        users.users.immich.extraGroups = [ "media" "data" ];

        # Pin PostgreSQL to version 17
        services.postgresql = {
          package = pkgs.postgresql_17;
        };

        # Nginx reverse proxy with SSL
        services.nginx = {
          enable = true;
          virtualHosts."immich" = {
            default = true;
            forceSSL = true;
            sslCertificate = "/etc/ssl/certs/selfsigned.crt";
            sslCertificateKey = "/etc/ssl/certs/selfsigned.key";
            locations."/" = {
              proxyPass = "http://localhost:${toString immich_port}";
              proxyWebsockets = true;

              extraConfig = ''
                client_max_body_size 16G;
              '';
            };
          };
        };

        # Additional firewall ports for immich
        networking.firewall.allowedTCPPorts = [
          22
          80
          443
        ];
      };
    };
  };
}
