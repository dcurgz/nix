{
  config,
  lib,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  keys = import "${FLAKE_ROOT}/keys" { inherit lib; };
  by = config.by.host-constants;
  secrets = config.by.git-secrets;
in
{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalization properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  # Enable sudo.
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  by.configure-ssh = {
    enable = true;
    groups = [
      {
        users = [ "root" "dcurgz" ];
        keys = keys.ssh.groups.privileged.paths;
      }
    ];
  };

  # Enable Fail2Ban for basic intrusion prevention.
  services.fail2ban.enable = true;

  networking = {
    hostName = "publicproxy-cax11-4gb";
    enableIPv6 = true;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
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
    #nat = {
    #  enable = true;
    #  internalInterfaces = [ "enp1s0" ];
    #  externalInterface = "tailscale0";
    #  forwardPorts = [
    #    {
    #      sourcePort = 25595;
    #      proto = "tcp";
    #      destination = "100.86.65.12:25565";
    #    }
    #    {
    #      sourcePort = 25595;
    #      proto = "udp";
    #      destination = "100.86.65.12:25565";
    #    }
    #  ];
    #};
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
    extraGroups = [
      "wheel"
    ];
    home = "/home/dcurgz";
  };
  users.groups.dcurgz = { };
  nix.settings.trusted-users = [ "dcurgz" ];

  programs.fish.enable = true;

  age.secrets.tailscale-auth-key.file = "${FLAKE_ROOT}/secrets/tailscale/hosts/publicproxy.age";

  services.tailscale = {
    enable = true; 
    authKeyFile = config.age.secrets.tailscale-auth-key.path;
    useRoutingFeatures = lib.mkDefault "both";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05";
}
