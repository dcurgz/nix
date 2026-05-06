{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-immich";
  immich_port = 8903;
  immich_media = "/data/immich";
  immich_db = "/data/immich-db";
in
{
  flake.modules.nixos.${hostName} = flake.lib.mkMicroVM
  {
      inherit hostName;
      system = "x86_64-linux";
      extraModules = [
        ### aspects
        flake.modules.nixos.packages-core
        flake.modules.nixos.linux-groups # media, data
        ### 3rd party modules
        inputs.agenix.nixosModules.default
      ];
      tags = with flake.tags; [ hyperberry-vm ];
    }

    ({
      config,
      pkgs,
      pkgs-immich,
      ...
    }:

    let
      secrets = config.by.git-secrets;
    in
    {
      by.guest.${hostName} = {
        networking = {
          macAddress = "02:00:00:00:00:02";
          ipAddress = "10.0.0.12";
        };
        tailscale = {
          enable = true;
          autologin = true;
        };
      };

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
        package = pkgs-immich.immich;
        openFirewall = true;
        host = "0.0.0.0";
        port = immich_port;
        database = {
          enable = true;
          createDB = true;
        };
      };

      users.users.immich.extraGroups = [ "media" "data" ];
      users.users.postgres.extraGroups = [ "data" ];

      # Nginx reverse proxy with SSL
      services.nginx =
        let
          address = secrets.hosts.vm-immich.ssh.hostName;
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
        file = "${FLAKE_ROOT}/secrets/tailscale/guests/${hostName}.age"; 
        mode = "0440"; 
      };
      services.tailscale.authKeyFile = config.age.secrets.tailscale-auth-key.path;
    });
}
