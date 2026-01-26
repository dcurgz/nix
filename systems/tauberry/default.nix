{
  config,
  pkgs,
  lib,
  globals,
  ...
}:

let
  keys = import ../../keys { };
  secrets = config.by.secrets;

  by = config.by.constants;
  inherit (by) NIXOS_PRESETS;
in
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

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  networking = {
    hostName = "tauberry";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
    };
    interfaces.end0 = {
      ipv4.addresses = [
        {
          address = "192.168.0.13";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "end0";
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  services.tailscale.enable = true;

  # Enable Avahi for network service discovery.
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

  services.openssh = {
    enable = true;
  };
  by.configure-ssh = {
    enable = true;
    groups = [
      {
        users = [ "tauberry" "root" ];
        keys = keys.ssh.groups.privileged;
      }
    ];
  };

  users = {
    mutableUsers = false;
    users.tauberry = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  programs.gnupg.agent.enable = true;

  nix.settings.trusted-users = [ "tauberry" ];

  ##########################################################################################
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # In the vast majority of cases, do not change this version.
  ##########################################################################################
  system.stateVersion = "24.11";
}
