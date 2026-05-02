{
  config,
  lib,
  pkgs,
  pkgs-immich,
  inputs,
  globals,
  ...
}:

let
  by = config.by.constants;
  secrets = config.by.secrets;
  inherit (globals) FLAKE_ROOT NIXOS_PRESETS;

  hostname = "vm-immich";
  immich_port = 8903;
  immich_media = "/data/immich";
  immich_db = "/data/immich-db";

  package = pkgs-immich.immich;
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:02";
        ipAddress = "10.0.0.12";
      };
      microvm = {
        extraModules = [
          inputs.agenix.nixosModules.default
        ];
        pkgs = pkgs-immich;
        config = { config, ... }: {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            # define media, data groups
            "${NIXOS_PRESETS}/security/groups"
          ];

          microvm.vcpu = 4;
          microvm.mem = 1024 * 8 + 1;
          microvm.shares = [
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

          nix.channel.enable = false;

          # Immich-specific packages
          environment.systemPackages = with pkgs; [
            immich-cli
          ];

          # Immich service configuration
          services.immich = {
            enable = true;
            inherit package;
            openFirewall = true;
            host = "0.0.0.0";
            port = immich_port;
            database = {
              enable = true;
              createDB = true;
            };
          };

          users.users.immich.extraGroups = [ "media" "data" ];

          # Pin PostgreSQL to version 17
          #services.postgresql = {
          #  package = pkgs.postgresql_17;
          #};

          users.users.postgres.extraGroups = [ "data" ];

          # Nginx reverse proxy with SSL
          services.nginx =
            let
              address = secrets.hosts.vm-immich.ssh.hostname;
            in
            {
              enable = true;
              virtualHosts."immich" = {
                default = true;
                forceSSL = true;
                sslCertificate = "/etc/ssl/certs/${address}.crt";
                sslCertificateKey = "/etc/ssl/certs/${address}.key";
                locations."/" = {
                  proxyPass = "http://localhost:${toString immich_port}";
                  proxyWebsockets = true;

                  extraConfig = ''
                    client_max_body_size 16G;
                  '';
                };
              };
            };

          users.users.nginx.extraGroups = [ "data" ];

          # Additional firewall ports for immich
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
