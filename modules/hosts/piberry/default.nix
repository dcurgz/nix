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
  flake.nixosConfigurations.piberry = flake.lib.mkNixOS rec {
    system = "aarch64-linux";
    specialArgs = {
      pkgs = prebuiltPackages.${system};
    };
    modules = with flake.modules; [
      (with flake.tags; flake.lib.use [
        flake-default
        nixos-base
        raspberry-pi
      ])
      nixos.piberry
      nixos.piberry-hardware
      nixos.authorized-keys
      {
        by.presets.authorized-keys.groups = [
          {
            users = [ "piberry" "root" ];
            keys = keys.ssh.groups.privileged.paths;
          }
        ];
      }
    ];
  };

  flake.modules.nixos.piberry = flake.lib.nixos.mkAspect (with flake.tags; [ hosts ])
    ({
      lib,
      pkgs,
      config,
      ...
    }:

    {
      boot = {
        kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
        initrd.availableKernelModules = [
          "xhci_pci"
          "usbhid"
          "usb_storage"
        ];
        loader = {
          grub.enable = false;
          generic-extlinux-compatible.enable = true;
        };
      };

      fileSystems."/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "noatime" ];
      };

      security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };

      networking = {
        hostName = "piberry";
        firewall = {
          enable = true;
          allowedTCPPorts = [
            22
            80
            443
          ];
        };
        interfaces.end0 = {
          ipv4.addresses = [
            {
              address = "192.168.0.11";
              prefixLength = 24;
            }
          ];
        };
        defaultGateway = {
          address = "192.168.0.1";
          interface = "end0";
        };
      };

      services.tailscale.enable = true;

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = false;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
      };

      services.openssh.enable = true;

      users = {
        mutableUsers = false;
        users.piberry = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };
      };

      systemd.tmpfiles.rules = [
        "Z /data 770 piberry data"
      ];

      environment.systemPackages = with pkgs; [
        vim
      ];

      nix.settings.trusted-users = [ "piberry" ];

      system.stateVersion = "24.11";
    });

  flake.deploy.nodes.piberry = {
    hostname = "piberry";
    sshUser = "piberry";
    remoteBuild = false;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos flake.nixosConfigurations.piberry;
    };
  };
}
