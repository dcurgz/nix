{
  inputs,
  lib,
  globals,
  prebuiltPackages,
  ...
} @args:

let
  inherit (globals) FLAKE_ROOT;
  inherit (args.config) flake;
  inherit (args.config.by) keys;
in
{
  flake.nixosConfigurations.publicproxy-cax11-4gb = flake.lib.mkNixOS rec {
    system = "aarch64-linux";
    specialArgs = {
      pkgs = prebuiltPackages.${system};
    };
    modules = with flake.modules; [
      (with flake.tags; flake.lib.use [
        flake-default
        nixos-base
      ])
      nixos.publicproxy-cax11-4gb
      nixos.publicproxy-cax11-4gb-hardware
      nixos.publicproxy-cax11-4gb-disk
      nixos.authorized-keys
      {
        by.presets.authorized-keys.groups = [
          {
            users = [ "root" "dcurgz" ];
            keys = keys.ssh.groups.privileged.paths;
          }
        ];
      }
    ];
  };

  flake.modules.nixos.publicproxy-cax11-4gb = flake.lib.nixos.mkAspect (with flake.tags; [ hosts ])
    ({
      lib,
      pkgs,
      config,
      ...
    }:

    {
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      boot.loader.efi.canTouchEfiVariables = true;

      time.timeZone = "Europe/London";

      i18n.defaultLocale = "en_GB.UTF-8";
      console.keyMap = "uk";

      security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };

      services.fail2ban.enable = true;

      networking = {
        hostName = "publicproxy-cax11-4gb";
        enableIPv6 = true;
        firewall = {
          enable = true;
          allowedTCPPorts = [
            22
            25595 # mc-leedlemon
          ];
          allowedUDPPorts = [
            25595 # mc-leedlemon
          ];
        };
        nftables = {
          enable = true;
          ruleset = ''
            table ip nat {
              chain PREROUTING {
                type nat hook prerouting priority dstnat; policy accept;
                iifname "enp1s0" tcp dport 25595 dnat to 100.86.65.12:25565
                iifname "enp1s0" udp dport 25595 dnat to 100.86.65.12:25565
              }

              chain POSTROUTING {
                type nat hook postrouting priority srcnat; policy accept;
                ip daddr 100.86.65.12 masquerade
              }
            }
          '';
        };
      };

      users.users.dcurgz = {
        isNormalUser = true;
        shell = pkgs.fish;
        group = "dcurgz";
        extraGroups = [ "wheel" ];
        home = "/home/dcurgz";
      };
      users.groups.dcurgz = { };
      nix.settings.trusted-users = [ "dcurgz" ];

      programs.fish.enable = true;

      age.secrets.tailscale-auth-key.file = "${FLAKE_ROOT}/agenix-secrets/agenix/tailscale/hosts/publicproxy.age";

      services.tailscale = {
        enable = true;
        authKeyFile = config.age.secrets.tailscale-auth-key.path;
        useRoutingFeatures = lib.mkDefault "both";
      };

      system.stateVersion = "24.05";
    });

  flake.deploy.nodes.publicproxy-cax11-4gb = {
    hostname = "publicproxy";
    sshUser = "root";
    remoteBuild = true;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos flake.nixosConfigurations.publicproxy-cax11-4gb;
    };
  };
}
