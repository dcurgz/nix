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
  keys = (import "${FLAKE_ROOT}/keys" { inherit lib; });

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

  # lord forgive me for my sins
  microvm = (pkgs.callPackage "${inputs.microvm}/nixos-modules/host/options.nix" { });
in
{
  options = {
    hyperberry.virtualization = {
      vms = mkOption {
        type = types.attrsOf (types.submodule ({ name, config, ... }: {
          options = {
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
            # Copied from microvm module, but with config tweaked.
            # https://github.com/microvm-nix/microvm.nix/blob/main/nixos-modules/host/options.nix
            microvm = mkOption {
              type = (types.submodule ({ name, config, ... }: {
                options = {
                  evaluatedConfig = mkOption {
                    description = ''
                      An already evaluated configuration of this MicroVM.
                      Allows supplying an already evaluated configuration or an alternative configuration evaluation function instead of NixOS's default eval-config.
                    '';
                    default = null;
                    type = nullOr types.unspecified;
                  };

                  config = mkOption {
                    description = ''
                      A specification of the desired configuration of this MicroVM,
                      as a NixOS module, for building **without** a flake.
                    '';
                    default = null;
                    type = types.nullOr types.deferredModule;
                  };

                  nixpkgs = mkOption {
                    type = types.path;
                    default = if config.pkgs != null then config.pkgs.path else pkgs.path;
                    defaultText = literalExpression "pkgs.path";
                    description = ''
                      This option is only respected when `config` is
                      specified.

                      The nixpkgs path to use for the MicroVM. Defaults to the
                      host's nixpkgs.
                    '';
                  };

                  pkgs = mkOption {
                    type = types.nullOr types.unspecified;
                    default = pkgs;
                    defaultText = literalExpression "pkgs";
                    description = ''
                      This option is only respected when `config` is specified.

                      The package set to use for the MicroVM. Must be a
                      nixpkgs package set with the microvm overlay. Determines
                      the system of the MicroVM.

                      If set to null, a new package set will be instantiated.
                    '';
                  };

                  specialArgs = mkOption {
                    type = types.attrsOf types.unspecified;
                    default = {};
                    description = ''
                      This option is only respected when `config` is specified.

                      A set of special arguments to be passed to NixOS modules.
                      This will be merged into the `specialArgs` used to evaluate
                      the NixOS configurations.
                    '';
                  };

                  extraModules = mkOption {
                    type = types.listOf types.deferredModule;
                    default = [];
                    description = ''
                      This option is only respected when `config` is specified.

                      A list of additional NixOS modules to be merged into
                      the MicroVM's system configuration.
                    '';
                    defaultText = literalExpression ''
                      [
                        flakeInputs.some-project.nixosModules.example
                        flakeInputs.another-project.nixosModules.default
                      ]
                    '';
                  };

                  flake = mkOption {
                    description = "Source flake for declarative build";
                    type = nullOr path;
                    default = null;
                    defaultText = literalExpression ''flakeInputs.my-infra'';
                  };

                  updateFlake = mkOption {
                    description = "Source flakeref to store for later imperative update";
                    type = nullOr str;
                    default = null;
                    defaultText = literalExpression ''"git+file:///home/user/my-infra"'';
                  };

                  autostart = mkOption {
                    description = "Add this MicroVM to config.microvm.autostart?";
                    type = bool;
                    default = true;
                  };

                  restartIfChanged = mkOption {
                    type = types.bool;
                    default = config.config != null;
                    description = ''
                      Restart this MicroVM's services if the systemd units are changed,
                      i.e. if it has been updated by rebuilding the host.

                      Defaults to true for fully-declarative MicroVMs.
                    '';
                  };
                };
              }));
            };
          };
        }));
      };
    };
  };

  config = {
    # Host-level tmpfiles configuration
    systemd.tmpfiles.rules = flatten (
      mapAttrsToList (
        hostname: vmConfig:
          [
            "d /var/lib/microvms/${hostname} 0750 microvm kvm"
            "d /var/lib/microvms/${hostname}/journal 0750 microvm kvm"
            "d /var/lib/microvms/${hostname}/tailscale 0750 microvm kvm"
            "d /var/lib/microvms/${hostname}/ssh-host-keys 0755 root root"
          ]
      ) config.hyperberry.virtualization.vms);

    # Host-level SSH configuration
    programs.ssh.extraConfig = concatStringsSep "\n" (
      mapAttrsToList (
        hostname: vmConfig:
        let
          ipAddress = vmConfig.networking.ipAddress;
        in
        ''
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
      # Apply berry guest defaults.
      {
        pkgs = 
          if (vmConfig.microvm.pkgs == null) then
            (import inputs.nixpkgs {
              system = "x86_64-linux";
            })
          else
            vmConfig.microvm.pkgs;

        specialArgs = vmConfig.microvm.specialArgs // {
          inherit inputs;
        };

        extraModules = vmConfig.microvm.extraModules ++ [
          vmConfig.microvm.config
        ];

        config = { config, ... } @args:
          {
            networking.hostName = hostname;
            microvm.hypervisor = mkDefault "cloud-hypervisor";
            system.stateVersion = mkDefault "24.11";

            networking.nameservers = [
              "1.1.1.1"
              "8.8.8.8"
            ];

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
                Address = "${vmConfig.networking.ipAddress}/24";
                Gateway = "10.0.0.1";
                DNS = [
                  "1.1.1.1"
                  "8.8.8.8"
                ];
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
            ];

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
            users.users.root.openssh.authorizedKeys.keyFiles = keys.ssh.hosts.hyperberry.paths;

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

            networking.firewall = {
              enable = mkDefault true;
              allowPing = mkDefault true;
            };

            boot.loader.systemd-boot.enable = mkDefault true;
            boot.loader.timeout = mkDefault 1;

            services.tailscale.enable = mkDefault true;
          };
      }
    ) config.hyperberry.virtualization.vms;
  };
}
