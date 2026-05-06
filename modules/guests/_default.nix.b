{
  inputs,
  lib,
  globals,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;
in
{
  flake.modules.nixos.guest-vms = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      microvm.vms = lib.mapAttrs (hostName: vm:
      {
        # Note, overriding this changes the system of the MicroVM.
        pkgs = vm.microvm.pkgs || (import inputs.nixpkgs {
          system = "x86_64-linux";
        });
        specialArgs = vm.microvm.specialArgs // { inherit inputs; };
        extraModules = vm.microvm.extraModules ++ vm.microvm.config;
        config = { config, ... } @args: {
          imports = [
            flake.modules.nixos.lix._module
            flake.modules.nixos.dns._module
            flake.modules.nixos.packages-core._module
          ];

          microvm.hypervisor = lib.mkDefault "cloud-hypervisor";
          system.stateVersion = lib.mkDefault "24.11";

          nix.nixPath = [
            "nixpkgs=${pkgs.path}"
          ];

          microvm.interfaces = lib.mkDefault [
            {
              type = "tap";
              id = hostName;
              mac = vm.networking.macAddress;
            }
          ];

          networking.useNetworkd = lib.mkDefault true;
          systemd.network.enable = lib.mkDefault true;

          networking.firewall = {
            enable = lib.mkDefault true;
            allowPing = lib.mkDefault true;
          };

          systemd.network.networks."20-lan" = {
            matchConfig.Type = "ether";
            networkConfig = {
              Address = "${vm.networking.ipAddress}/${vm.networking.ipSubnet}";
              Gateway = "${vm.networking.gateway}";
            };
          };

          microvm.shares = [
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
            }
            {
              source = "/var/lib/microvms/${hostName}/journal";
              mountPoint = "/var/log/journal";
              tag = "journal";
              proto = "virtiofs";
              socket = "journal.sock";
            }
            {
              source = "/var/lib/microvms/${hostName}/tailscale";
              mountPoint = "/var/lib/tailscale";
              tag = "tailscale";
              proto = "virtiofs";
              socket = "tailscale.sock";
            }
            {
              source = "/var/lib/microvms/${hostName}/ssh-host-keys";
              mountPoint = "/var/lib/ssh-host-keys";
              tag = "ssh-host-keys";
              proto = "virtiofs";
              socket = "ssh-host-keys.sock";
            }
            {
              source = "/var/lib/microvms/${hostName}/root-home";
              mountPoint = "/root";
              tag = "root-home";
              proto = "virtiofs";
              socket = "root-home.sock";
            }
          ];

          services.openssh = {
            enable = lib.mkDefault true;
            settings = {
              PasswordAuthentication = lib.mkDefault false;
              PermitRootLogin = lib.mkDefault "prohibit-password";
            };
            hostKeys = [
              {
                path = "/var/lib/ssh-host-keys/ssh_host_ed25519_key";
                type = "ed25519";
              }
              {
                path = "/var/lib/ssh-host-keys/ssh_host_rsa_key";
                type = "rsa";
                bits = 4096;
              }
            ];
          };

          # This allows the Agenix module to decrypt secrets during early boot.
          fileSystems = {
            "/var/lib/ssh-host-keys" = {
              neededForBoot = true;
            };
          };

          boot.loader.systemd-boot.enable = lib.mkDefault true;
          boot.loader.timeout = lib.mkDefault 1;

          age.secrets.tailscale-auth-key = lib.mkIf (vm.tailscale.enable && vm.tailscale.autologin) {
            file = "${FLAKE_ROOT}/secrets/tailscale/guests/${hostName}.age"; 
            mode = "0440"; 
          };

          services.tailscale = lib.mkIf (vm.tailscale.enable) {
            enable = true;
            authKeyFile = lib.mkIf (vm.tailscale.autologin) config.age.secrets.tailscale-auth-key.path;
          };
        };
      }) config.by.guests;
    });
}
