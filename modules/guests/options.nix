{
  inputs,
  lib,
  globals,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  guestOptions = {
    networking = {
      macAddress = lib.mkOption {
        type = lib.types.str;
        description = "MAC address for the VM's TAP interface";
        example = "02:00:00:01:01:01";
      };

      ipAddress = lib.mkOption {
        type = lib.types.str;
        description = "IP address for the VM";
        example = "10.0.0.10";
      };

      ipSubnet = lib.mkOption {
        type = lib.types.str;
        description = "The IP subnet that the IP address belongs in.";
        default = "24";
      };

      gateway = lib.mkOption {
        type = lib.types.str;
        description = "Gateway IP address for the virtual interface";
        default = "10.0.0.1";
      };

      forwardPorts = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            source = lib.mkOption {
              type = lib.types.int;
              example = 8080;
            };
            target = lib.mkOption {
              type = lib.types.int;
              example = 80;
            };
            proto = lib.mkOption {
              type = lib.types.enum [ "udp" "tcp" ];
              example = "udp";
            };
          };
        });
        description = "A list of port forwarding configurations.";
        default = [ ];
      };
    };
    tailscale = {
      enable = lib.mkEnableOption "Enable Tailscale daemon inside the guest.";
      autologin = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Use a Tailscale auth key in the flake root to automatically login to Tailscale.

          Expects $${FLAKE_ROOT}/agenix-secrets/tailscale/guests/$${hostName}.age to exist.
        '';
      };
    };
  };
in
{
  flake.lib.mkMicroVM = 
    {
      hostName,
      system,
      extraModules,
      pkgs ? null,
      specialArgs ? { }, 
      tags ? [ ],
    }: config':

    let
      flat = lib.lists.flatten extraModules;
      aspects = builtins.filter (a: builtins.isAttrs a && a ? "_type" && a._type == "aspect") flat;
      nixosAspects = builtins.filter (a: a.class == "nixos") aspects;
      nixosModules = lib.lists.subtractLists aspects flat;

      baseAspects = [
        flake.modules.nixos.lix
        flake.modules.nixos.dns
        flake.modules.nixos.packages-core
      ];
      baseModules = [
        config'
        {
          options.by.guest = guestOptions;
        }
      ];
    in

    flake.lib.nixos.mkAspect tags 
    ({
      config,
      ...
    }:

    let
      vm = config.by.guest;
    in
    {
      microvm.vms.${hostName} = {
        pkgs = lib.trivial.defaultTo
          inputs.nixpkgs.legacyPackages.${system}
          pkgs;
        specialArgs = specialArgs // { inherit inputs; };
        extraModules =
          nixosModules
          ++ baseModules
          ++ (builtins.map (aspect: aspect._module) (nixosAspects ++ baseAspects));
        config = { config, ... }: {
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
      };
    });
}
