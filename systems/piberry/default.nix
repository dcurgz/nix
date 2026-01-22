{
  config,
  pkgs,
  lib,
  globals,
  ...
}:

let
  keys = import ../../keys { };
  secrets = config.by.secrets.piberry;

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
        users = [ "piberry" "root" ];
        keys = keys.ssh.groups.privileged;
      }
    ];
  };

  users = {
    mutableUsers = false;
    users.piberry = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  # Import modules.
  imports = [
  ];

  programs.gnupg.agent.enable = true;

  age.secrets.cloudflare-key.file = ../../secrets/piberry/cloudflare-key.age;

  # Configure reverse proxy.
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "${secrets.home-assistant.subdomain}" = {
        forceSSL = true;
        enableACME = true;
        # Disable ACME challenge generation to force DNS-01.
        acmeRoot = null;
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://[::1]:8123";
          proxyWebsockets = true;
        };
      };
      "${secrets.tailscale.address}" = {
        forceSSL = true;
        sslCertificate = "/etc/ssl/certs/${secrets.tailscale.address}.crt";
        sslCertificateKey = "/etc/ssl/certs/${secrets.tailscale.address}.key";
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://[::1]:8123";
          proxyWebsockets = true;
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = secrets.home-assistant.acme.email;
    certs = {
      "${secrets.home-assistant.subdomain}" = {
        domain = "*.${secrets.home-assistant.domain}";
        group = "nginx";
        dnsProvider = "cloudflare";
        # location of your CLOUDFLARE_DNS_API_TOKEN=[value]
        environmentFile = config.age.secrets.cloudflare-key.path;
      };
    };
  };

  ##########################################################################################
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # In the vast majority of cases, do not change this version.
  ##########################################################################################
  system.stateVersion = "24.11";
}
