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

  hostname = "vm-vikunja";
  vikunja_data = "/data/vikunja";
  vikunja_http = 8096;

  frontend_hostname = secrets.hosts.vm-vikunja.ssh.hostname;
in
{
  systemd.tmpfiles.rules = [
    "d ${vikunja_data} 770 root data -"
  ];

  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:11";
        ipAddress = "10.0.0.21";
      };
      microvm = {
        extraModules = [
          inputs.agenix.nixosModules.default
        ];
        config = { config, ...}: {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            "${NIXOS_PRESETS}/security/groups"
          ];

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

          age.secrets.tailscale-auth-key = {
            file = "${FLAKE_ROOT}/secrets/tailscale/guests/${hostname}.age"; 
            mode = "0440"; 
            #group = "kvm";
          };
          services.tailscale.authKeyFile = config.age.secrets.tailscale-auth-key.path;

          fileSystems = {
            "/var/lib/ssh-host-keys" = {
              #device = "ssh-host-keys";
              #fsType = "virtiofs";
              neededForBoot = true;
            };
          };

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
        };
      };
    };
  };
}
