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

  hostname = "vm-claude";
  workspace = "/data/claude-workspace";
in
{
  systemd.tmpfiles.rules = [
    "d ${workspace} 770 root data -"
    "d /var/lib/microvms/${hostname}/rw-store 0755 root root"
  ];

  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:15";
        ipAddress = "10.0.0.25";
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

          environment.systemPackages = with pkgs; [
            (pkgs.writeShellScriptBin "claude" ''
              IS_SANDBOX=1 TERMCOLORS=truecolor exec ${lib.getExe pkgs.claude-code} --dangerously-skip-permissions $@
            '')
            opencode
          ];

          microvm.vcpu = 2;
          microvm.mem = 1024 * 8 + 1;
          microvm.shares = [
            # claude data directory
            {
              source = workspace;
              mountPoint = "/workspace";
              tag = "claude-workspace";
              proto = "virtiofs";
              socket = "claude-workspace.sock";
            }
            # SSL certificates
            {
              source = "/etc/ssl/certs";
              mountPoint = "/etc/ssl/certs";
              tag = "ssl-certs";
              proto = "virtiofs";
              socket = "ssl-certs.sock";
            }
            # rw-store
            {
              source = "/var/lib/microvms/${hostname}/rw-store";
              mountPoint = "/nix/.rw-store";
              tag = "rw-store";
              proto = "virtiofs";
              socket = "rw-store.sock";
            }
          ];
          microvm.writableStoreOverlay = "/nix/.rw-store";

          age.secrets.tailscale-auth-key = {
            file = "${FLAKE_ROOT}/secrets/tailscale/guests/${hostname}.age"; 
            mode = "0440"; 
          };
          services.tailscale.authKeyFile = config.age.secrets.tailscale-auth-key.path;

          fileSystems = {
            "/var/lib/ssh-host-keys" = {
              neededForBoot = true;
            };
          };

          nix.channel.enable = false;

          systemd.tmpfiles.rules = [
            "Z /etc/ssl/certs 550 root data"
          ];

          networking.firewall.allowedTCPPorts = [
            22
          ];
        };
      };
    };
  };
}
