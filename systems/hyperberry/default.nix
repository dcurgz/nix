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
  by = config.by.constants;
in
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalization properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "uk";
  };

  # Allow building aarch64 and armv7l via QEMU as a remote host.
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv7l-linux"
  ];

  # Enable binary cache to make installing CUDA take a sane amount of time.
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    system-features = [
      "gccarch-armv7-a"
    ];
  };

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
      {
        users = [ "builder" ];
        keys = keys.ssh.groups.privileged.paths ++ keys.ssh.groups.wg.paths;
      }
    ];
  };

  # Enable Fail2Ban for basic intrusion prevention.
  services.fail2ban.enable = true;

  # Enable Docker service.
  virtualisation.docker.enable = true;

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

  # Enable vsftpd for FTP service.
  services.vsftpd = {
    enable = true;
    localRoot = "/data";
  };

  services.resolved = {
    enable = true;
  };

  # Setup networking.
  networking = {
    hostName = "hyperberry";
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
        25565
        25566
      ];
      allowedUDPPorts = [
        25565
        25566
        #dns
        67
        68
      ];
    };
    interfaces."${by.hardware.interfaces.ethernet}" = {
      ipv4.addresses = [{
        address = "192.168.0.10";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = by.hardware.interfaces.ethernet;
    };
  };

  # Configure systemd-networkd for MicroVM networking
  systemd.network.enable = true;
  networking.useNetworkd = true;

  # Configure bridge for MicroVMs
  systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-lan-bridge-config" = {
    matchConfig.Name = [
      "eth0"
      "vm-*"
    ];
    networkConfig = {
      Bridge = "br0";
    };
  };

  systemd.network.networks."20-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = [ "10.0.0.1/24" ];
      DHCPServer = true;
      IPv6SendRA = true;
    };
  };

  # Allow internet access
  networking.nat = {
    enable = true;
    externalInterface = "eno1";
    internalInterfaces = [
      "br0"
    ];
    #TODO: isn't this abstracted?
    forwardPorts =
    let
      vms = config.hyperberry.virtualization.vms;
      wg-0 = vms.vm-mc-wg-0.networking.ipAddress;
      #wg-1 = vms.vm-mc-wg-1.networking.ipAddress;
    in
    [
      {
        sourcePort = 25565;
        destination = "${wg-0}:25565";
        proto = "tcp";
      }
      {
        sourcePort = 25565;
        destination = "${wg-0}:25565";
        proto = "udp";
      }
      #{
      #  sourcePort = 25566;
      #  destination = "${wg-1}:25565";
      #  proto = "tcp";
      #}
      #{
      #  sourcePort = 25566;
      #  destination = "${wg-1}:25565";
      #  proto = "udp";
      #}
    ];
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = lib.mkDefault "both";

  programs.command-not-found.enable = true;
  programs.fish.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  age.secrets = {
    restic-password.file = "${FLAKE_ROOT}/secrets/backup/restic-password.age";
    restic-envvars.file = "${FLAKE_ROOT}/secrets/backup/restic-envvars.age";
  };

  by.restic.enable = true;
  by.restic.defaults = {
    initialize = true;
    pruneOpts = [
      "--keep-daily=2"
      "--keep-weekly=2"
    ];
    timerConfig = {
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
    };
    repository = "s3:s3.eu-central-1.s4.mega.io/restic-hyperberry-data";
    passwordFile = config.age.secrets.restic-password.path;
    environmentFile = config.age.secrets.restic-envvars.path;
    progressFps = 0.5;
  };
  by.restic.backups = {
    hyperberry-media-photos = {
      paths = [ "/media/photos" ];
      pruneOpts = [
        "--keep-daily=7"
        "--keep-weekly=1"
        "--keep-monthly=1"
      ];
      repository = "s3:s3.eu-central-1.s4.mega.io/restic-hyperberry-media";
      timerConfig.OnCalendar = "*-*-* 06:00:00";
    };
    hyperberry-data-immich = {
      paths = [
        "/data/immich"
        "/data/immich-db"
      ];
      timerConfig.OnCalendar = "*-*-* 06:15:00";
    };
    hyperberry-data-mc-slime = {
      paths = [
        "/data/minecraft-slime"
      ];
      pruneOpts = [
        "--keep-daily=7"
        "--keep-weekly=1"
        "--keep-monthly=1"
      ];
      timerConfig.OnCalendar = "*-*-* 06:30:00";
    };
    hyperberry-data-mc-wg-0 = {
      paths = [
        "/data/minecraft-wg-0"
      ];
      pruneOpts = [
        "--keep-daily=7"
        "--keep-weekly=1"
        "--keep-monthly=1"
      ];
      timerConfig.OnCalendar = "*-*-* 06:45:00";
    };
    hyperberry-data-teamspeak = {
      paths = [
        "/data/teamspeak"
      ];
      timerConfig.OnCalendar = "*-*-* 07:00:00";
    };
  };

  # Define users.
  users.users.dcurgz = {
    isNormalUser = true;
    shell = pkgs.fish;
    group = "dcurgz";
    extraGroups = [
      "wheel"
      "docker"
      "media"
      "data"
    ];
    home = "/home/dcurgz";
  };
  users.groups.dcurgz = { };
  users.users.builder = {
    isNormalUser = true;
    shell = pkgs.bashInteractive;
    group = "builder";
  };
  users.groups.builder = { };
  nix.settings.trusted-users = [ "dcurgz" "builder" ];

  systemd.tmpfiles.rules = [
    "Z /etc/nixos 770 root wheel"
    "Z /media 770 root media" 
    "Z /data 770 root data" 
  ];

  ##########################################################################################
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # In the vast majority of cases, do not change this version.
  ##########################################################################################
  system.stateVersion = "24.11";
}
