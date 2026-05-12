{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-vikunja";
  vikunja_data = "/data/vikunja";
  vikunja_http = 8096;
in
{
  flake.modules.nixos.${hostName} = flake.lib.mkMicroVM
    rec {
      enable = true;
      inherit hostName;
      system = "x86_64-linux";
      extraModules = [
        ### aspects
        ### 3rd party modules
        inputs.agenix.nixosModules.default
      ];
      microvmConfig = {
        networking = {
          macAddress = "02:00:00:00:00:11";
          ipAddress = "10.0.0.21";
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
      frontend_hostname = secrets.hosts.${hostName}.ssh.hostName;
    in
    {
      microvm.vcpu = 2;
      microvm.mem = 1024 * 2 + 1;
      microvm.shares = [
        # vikunja data directory
        {
          source = vikunja_data;
          mountPoint = vikunja_data;
          tag = "vikunja-data";
          proto = "virtiofs";
          socket = "vikunja-data.sock";
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

      services.vikunja = {
        enable = true;
        database.path = "${vikunja_data}/vikunja.db";
        frontendScheme = "http";
        frontendHostname = frontend_hostname;
        address = "127.0.0.1";
        port = vikunja_http;
      };

      systemd.services.vikunja.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User  = "vikunja";
        Group = "vikunja";
      };

      users.users.vikunja.isSystemUser = true;
      users.users.vikunja.group = "vikunja";
      users.users.vikunja.extraGroups = [ "data" ];
      users.groups.vikunja = {};

      # Nginx reverse proxy with SSL
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        virtualHosts."${frontend_hostname}" = {
          default = true;
          forceSSL = true;
          sslCertificate = "/etc/ssl/certs/${frontend_hostname}.crt";
          sslCertificateKey = "/etc/ssl/certs/${frontend_hostname}.key";
          locations."/" = {
            proxyPass = "http://localhost:${toString vikunja_http}";
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
    });
}
