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

  hostname = "vm-trilium";
  trilium_data = "/data/trilium-data";
  trilium_http = 8096;
in
{

  systemd.tmpfiles.rules = [
    "d ${trilium_data} root data"
  ];

  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:14";
        ipAddress = "10.0.0.24";
      };
      
      microvm = {
        config = { config, ... }: {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            "${NIXOS_PRESETS}/security/groups"
            inputs.agenix.nixosModules.default
          ];

          microvm.vcpu = 4;
          microvm.mem = 1024 * 3 + 1;
          microvm.shares = [
            # trilium data directory
            {
              source = trilium_data;
              mountPoint = trilium_data;
              tag = "trilium-data";
              proto = "virtiofs";
              socket = "trilium-data.sock";
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

          services.trilium-server = {
            enable = true;
            dataDir = trilium_data;
            host = "127.0.0.1";
            port = trilium_http;
            instanceName = "vm-trilium";
          };

          users.users.trilium.extraGroups = [ "media" "data" ];

          # Nginx reverse proxy with SSL
          services.nginx =
            let
              address = secrets.hosts.vm-trilium.ssh.hostname;
            in
            {
              enable = true;
              recommendedProxySettings = true;
              recommendedGzipSettings = true;
              recommendedOptimisation = true;
              recommendedTlsSettings = true;
              virtualHosts."${address}" = {
                default = true;
                forceSSL = true;
                sslCertificate = "/etc/ssl/certs/${address}.crt";
                sslCertificateKey = "/etc/ssl/certs/${address}.key";
                locations."/" = {
                  proxyPass = "http://localhost:${toString trilium_http}";
                  proxyWebsockets = true;
                };
              };
            };

          users.users.nginx.extraGroups = [ "data" ]; # for certs

          age.secrets.tailscale-auth-key = {
            file = "${FLAKE_ROOT}/secrets/tailscale/guests/${hostname}.age"; 
            mode = "0440"; 
          };
          services.tailscale.authKeyFile = config.age.secrets.tailscale-auth-key.path;

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
