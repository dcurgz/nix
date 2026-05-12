{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-claude";
  workspace = "/data/claude-workspace";
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
          macAddress = "02:00:00:00:00:15";
          ipAddress = "10.0.0.25";
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

    {
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
          source = "/var/lib/microvms/${hostName}/rw-store";
          mountPoint = "/nix/.rw-store";
          tag = "rw-store";
          proto = "virtiofs";
          socket = "rw-store.sock";
        }
      ];
      microvm.writableStoreOverlay = "/nix/.rw-store";

      nix.channel.enable = false;

      environment.systemPackages = with pkgs; [
        (pkgs.writeShellScriptBin "claude" ''
          IS_SANDBOX=1 TERMCOLORS=truecolor exec ${lib.getExe pkgs.claude-code} --dangerously-skip-permissions $@
        '')
        opencode
      ];

      systemd.tmpfiles.rules = [
        "Z /etc/ssl/certs 550 root data"
      ];

      networking.firewall.allowedTCPPorts = [
        22
      ];
    });
}
