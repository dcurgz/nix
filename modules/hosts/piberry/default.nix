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

  hostName = "piberry";

  lib'.mkRaspberryPi =
    {
      system,
      modules,
      specialArgs ? { },
    } @args:
  
    let
      flat = lib.lists.flatten modules;
      aspects = builtins.filter (a: builtins.isAttrs a && a ? "_type" && a._type == "aspect") flat;
      nixosAspects = builtins.filter (a: a.class == "nixos") aspects;
      baseModules = [
        {
          nixpkgs.overlays = (import "${FLAKE_ROOT}/overlays" {
            inherit inputs globals;
            inherit (inputs.nixpkgs) lib;
          });
        }
      ];
      nixosModules = lib.lists.subtractLists aspects flat;
    in
      inputs.nixos-raspberrypi.lib.nixosSystem {
        inherit system;
        modules = baseModules ++ nixosModules ++ (builtins.map (aspect: aspect._module) nixosAspects);
        specialArgs = specialArgs // { _classArgs = args; };
      };
in
{
  flake.nixosConfigurations.piberry = lib'.mkRaspberryPi rec {
    system = "aarch64-linux";
    modules = with flake.modules; [
      (with flake.tags; flake.lib.use [
        flake-default
        nixos-base
        raspberry-pi
      ])
      nixos.piberry
      nixos.piberry-hardware
      # Raspberry Pi modules
      (with inputs.nixos-raspberrypi.nixosModules; [
        raspberry-pi-4.base
      ])
      nixos.authorized-keys
      {
        by.presets.authorized-keys.groups = [
          {
            users = [ "piberry" "root" ];
            keys = keys.ssh.groups.privileged.paths;
          }
        ];
      }
      # Linux
      nixos.avahi
      # Services
      nixos.home-assistant
      nixos.matter
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
        inherit hostName;
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

      age.secrets.tailscale-auth-key.file = "${FLAKE_ROOT}/agenix-secrets/agenix/tailscale/hosts/${hostName}.age";
    
      services.tailscale = {
        enable = true; 
        authKeyFile = config.age.secrets.tailscale-auth-key.path;
        useRoutingFeatures = lib.mkDefault "both";
      };

      system.stateVersion = "24.11";
    });

  flake.deploy.nodes.piberry = {
    hostname = "piberry.local";
    sshUser = "piberry";
    remoteBuild = false;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos flake.nixosConfigurations.piberry;
    };
  };
}
