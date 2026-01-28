{
  config,
  lib,
  pkgs,
  inputs,
  globals,
  ...
}:

with lib;

let
  inherit (globals) FLAKE_ROOT;
  keys = (import "${FLAKE_ROOT}/keys" { });

  portsType = types.submodule (_: {
    options = {
      source = mkOption {
        type = types.int;
        example = 8080;
      };
      target = mkOption {
        type = types.int;
        example = 80;
      };
      proto = mkOption {
        type = types.enum [ "udp" "tcp" ];
        example = "udp";
      };
    };
  });

  vmType = types.submodule (
    { name, config, ... }:
    {
      options = {
        enable = mkEnableOption "Enable this virtual machine";

        vcpus = mkOption {
          type = types.int;
          default = 2;
          description = "Number of vCPUs to allocate to this VM";
        };

        memory = mkOption {
          type = types.int;
          #2048 causes qemu crash
          default = 2054;
          description = "Memory in MB to allocate to this VM";
        };

        mounts = mkOption {
          type = types.listOf types.attrs;
          default = [ ];
          description = "Additional filesystem shares beyond the common ones";
          example = literalExpression ''
            [
              {
                source = "/host/path";
                mountPoint = "/guest/path";
                tag = "custom-share";
                proto = "virtiofs";
              }
            ]
          '';
        };

        networking = {
          macAddress = mkOption {
            type = types.str;
            description = "MAC address for the VM's TAP interface";
            example = "02:00:00:01:01:01";
          };

          ipAddress = mkOption {
            type = types.str;
            description = "IP address for the VM";
            example = "10.0.0.10";
          };

          forwardPorts = mkOption {
            type = types.listOf portsType;
            description = "A list of port forwarding configurations.";
            default = [ ];
          };
        };

        config = mkOption {
          type = types.attrs;
          default = { };
          description = "Additional NixOS configuration to pass to the MicroVM";
          example = literalExpression ''
            {
              services.nginx.enable = true;
              networking.firewall.allowedTCPPorts = [ 80 443 ];
            }
          '';
        };

        tmpfiles = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Additional systemd tmpfiles rules for the host";
        };

        nixpkgsConfig = mkOption {
          type = types.attrs;
          default = { };
          description = "Additional nixpkgs configuration for the VM";
        };
      };
    }
  );
in
{
  options = {
    hyperberry.virtualization = {
      vms = mkOption {
        type = types.attrsOf vmType;
        default = { };
        description = "Virtual machines configuration";
        example = literalExpression ''
          {
            myvm = {
              enable = true;
              vcpus = 4;
              memory = 4096;
              networking = {
                macAddress = "02:00:00:01:01:01";
                ipAddress = "10.0.0.10";
              };
              config = {
                services.nginx.enable = true;
              };
            };
          }
        '';
      };
    };
  };

  config = {
    # Host-level tmpfiles configuration
    systemd.tmpfiles.rules = flatten (
      mapAttrsToList (
        hostname: vmConfig:
        optionals vmConfig.enable (
          [
            "d /var/lib/microvms/${hostname} 0750 microvm kvm"
            "d /var/lib/microvms/${hostname}/journal 0750 microvm kvm"
            "d /var/lib/microvms/${hostname}/tailscale 0750 microvm kvm"
            "d /var/lib/microvms/${hostname}/ssh-host-keys 0755 root root"
          ]
          ++ vmConfig.tmpfiles
        )
      ) config.hyperberry.virtualization.vms
    );

    # Host-level SSH configuration
    programs.ssh.extraConfig = concatStringsSep "\n" (
      mapAttrsToList (
        hostname: vmConfig:
        let
          ipAddress = vmConfig.networking.ipAddress;
        in
        optionalString vmConfig.enable ''
          Host ${hostname}
            HostName ${ipAddress}
            User root
        ''
      ) config.hyperberry.virtualization.vms
    );

    networking.nat = {
      forwardPorts = lib.lists.flatten (mapAttrsToList (_: vmConfig:
        (map (portConfig: {
          sourcePort = portConfig.source;
          destination = "${vmConfig.networking.ipAddress}:${builtins.toString portConfig.target}";
          proto = portConfig.proto;
        }) vmConfig.networking.forwardPorts)
      ) config.hyperberry.virtualization.vms);
    };

    # MicroVM definitions
    microvm.vms = mapAttrs (
      hostname: vmConfig:
      mkIf vmConfig.enable {
        # Use x86_64-linux system for the VM
        pkgs = import inputs.nixpkgs (
          {
            system = "x86_64-linux";
          }
          // vmConfig.nixpkgsConfig
        );

        # Pass inputs as specialArgs to the VM configuration
        specialArgs = {
          inherit inputs;
        };

        config = mkMerge [
          {
            # Basic VM configuration
            networking.hostName = hostname;
            system.stateVersion = mkDefault "24.11";

            # Configure networking
            networking.nameservers = [
              "1.1.1.1"
              "8.8.8.8"
            ];

            # Configure TAP interface
            microvm.interfaces = [
              {
                type = "tap";
                id = hostname;
                mac = vmConfig.networking.macAddress;
              }
            ];

            networking.useNetworkd = true;
            systemd.network.enable = true;

            systemd.network.networks."20-lan" = {
              matchConfig.Type = "ether";
              networkConfig = {
                #TODO: configurable subnet mask?
                Address = "${vmConfig.networking.ipAddress}/24";
                Gateway = "10.0.0.1";
                DNS = [
                  "1.1.1.1"
                  "8.8.8.8"
                ];
              };
            };

            # MicroVM resource constraints
            microvm.mem = vmConfig.memory;
            microvm.vcpu = vmConfig.vcpus;

            # Filesystem shares
            microvm.shares = [
              {
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
                tag = "ro-store";
                proto = "virtiofs";
              }
              {
                source = "/var/lib/microvms/${hostname}/journal";
                mountPoint = "/var/log/journal";
                tag = "journal";
                proto = "virtiofs";
                socket = "journal.sock";
              }
              {
                source = "/var/lib/microvms/${hostname}/tailscale";
                mountPoint = "/var/lib/tailscale";
                tag = "tailscale";
                proto = "virtiofs";
                socket = "tailscale.sock";
              }
              {
                source = "/var/lib/microvms/${hostname}/ssh-host-keys";
                mountPoint = "/var/lib/ssh-host-keys";
                tag = "ssh-host-keys";
                proto = "virtiofs";
                socket = "ssh-host-keys.sock";
              }
            ] ++ vmConfig.mounts;

            # SSH configuration
            services.openssh = {
              enable = mkDefault true;
              settings = {
                PasswordAuthentication = mkDefault false;
                PermitRootLogin = mkDefault "prohibit-password";
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

            # Configure root user SSH keys
            users.users.root.openssh.authorizedKeys.keyFiles = keys.ssh.hosts.hyperberry;

            # Network diagnostics and utilities
            environment.systemPackages = mkDefault (
              with pkgs;
              [
                curl
                wget
                dig
                iproute2
                iputils
                htop
                tmux
                vim
                less
              ]
            );

            # Firewall configuration
            networking.firewall = {
              enable = mkDefault true;
              allowPing = mkDefault true;
            };

            # Boot configuration
            boot.loader.systemd-boot.enable = mkDefault true;
            boot.loader.timeout = mkDefault 1;

            # Tailscale for remote access
            services.tailscale.enable = mkDefault true;
          }

          # User-provided configuration
          vmConfig.config
        ];
      }
    ) config.hyperberry.virtualization.vms;
  };
}
