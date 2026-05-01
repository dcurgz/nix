{
  config,
  lib,
  pkgs,
  pkgs-ollama,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  keys = import "${FLAKE_ROOT}/keys" { inherit lib; };
  by = config.by.constants;

  ollamaDir = "/data/open-webui.ollama";
in
{
  age.secrets.br1-wg-key = {
    file = "${FLAKE_ROOT}/secrets/wireguard/001-key.age";
  };

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
      checkReversePath = "loose";
      allowedTCPPorts = [
        22
      ];
      interfaces."br0".allowedTCPPorts = [
        11434 # ollama
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

  systemd.network.netdevs."br1" = {
    netdevConfig = {
      Name = "br1";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-add-interfaces-to-br0" = {
    matchConfig.Name = [
      "vm-*"
    ];
    networkConfig = {
      Bridge = "br0";
    };
  };

  systemd.network.networks."20-add-interfaces-to-br1" = {
    matchConfig.Name = [
      "vx-*"
    ];
    networkConfig = {
      Bridge = "br1";
    };
  };

  systemd.network.networks."30-configure-gateway-for-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = [ "10.0.0.1/24" ];
      DHCPServer = true;
      IPv6SendRA = true;
    };
  };

  systemd.network.networks."40-configure-gateway-for-br1" = {
    matchConfig.Name = "br1";
    networkConfig = {
      Address = [ "10.0.9.1/24" ];
      DHCPServer = true;
      IPv6SendRA = true;
    };
  };

  # Allow internet access
  networking.nat = {
    enable = true;
    externalInterface = by.hardware.interfaces.ethernet;
    internalInterfaces = [ "br0" ];
  };

  networking.wg-quick.interfaces."wg0" =
    let
      ip = "${pkgs.iproute2}/bin/ip";
      nft = lib.getExe pkgs.nftables;
      git-secrets = config.by.secrets.wireguard."001";
      br1-subnet = "10.0.9.0/24";
    in
    {
      table = "off";
      inherit (git-secrets) address;
      peers = [
        {
          inherit (git-secrets) endpoint publicKey;
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
        }
      ];
      privateKeyFile = config.age.secrets.br1-wg-key.path;
      postUp = ''
        # Policy routing: send br1 subnet traffic via wg0
        ${ip} route add ${br1-subnet} dev br1 table 51820
        ${ip} route add default dev wg0 table 51820
        ${ip} rule add from ${br1-subnet} table 51820 priority 100

        # Forward br1 traffic through wg0
        ${nft} add table inet wg-br1
        ${nft} add chain inet wg-br1 forward '{ type filter hook forward priority 0; policy accept; }'
        ${nft} add rule inet wg-br1 forward iifname "br1" oifname "wg0" accept
        ${nft} add rule inet wg-br1 forward iifname "wg0" oifname "br1" ct state established,related accept
        ${nft} add chain inet wg-br1 postrouting '{ type nat hook postrouting priority 100; }'
        ${nft} add rule inet wg-br1 postrouting oifname "wg0" ip saddr ${br1-subnet} masquerade
      '';
      postDown = ''
        ${ip} rule del from ${br1-subnet} table 51820 priority 100 || true
        ${ip} route del default dev wg0 table 51820 || true
        ${ip} route del ${br1-subnet} dev br1 table 51820 || true
        ${nft} delete table inet wg-br1
      '';
    };

  services.tailscale = {
    enable = true;
  };

  networking.nftables = {
    enable = true;
    tables."hyperberry" = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority -1; policy accept;
          # Block br1 from reaching ethernet directly (must use WireGuard)
          iifname "br1" oifname "${by.hardware.interfaces.ethernet}" drop
        }
      '';
    };
  };

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
      "--keep-daily=7"
      "--keep-weekly=8"
      "--keep-weekly=3"
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
  # WARNING: pruneOpts are currently global
  by.restic.backups = {
    hyperberry-media-photos = {
      paths = [ "/media/photos" ];
      repository = "s3:s3.eu-central-1.s4.mega.io/restic-hyperberry-media";
      timerConfig.OnCalendar = "*-*-* 06:00:00";
    };
    hyperberry-media-content = {
      paths = [ "/media/content" ];
      repository = "s3:s3.eu-central-1.s4.mega.io/restic-hyperberry-media";
      timerConfig.OnCalendar = "*-*-* 06:05:00";
    };
    hyperberry-data-immich = {
      paths = [
        "/data/immich"
        "/data/immich-db"
      ];
      timerConfig.OnCalendar = "*-*-* 06:15:00";
    };
    hyperberry-data-jellyfin = {
      paths = [
        "/data/jellyfin-data"
      ];
      timerConfig.OnCalendar = "*-*-* 06:35:00";
    };
    hyperberry-data-openwebui = {
      paths = [
        "/data/openwebui"
      ];
      timerConfig.OnCalendar = "*-*-* 06:45:00";
    };
    hyperberry-data-mc-slime = {
      paths = [
        "/data/minecraft-slime"
      ];
      timerConfig.OnCalendar = "*-*-* 07:00:00";
    };
    hyperberry-data-mc-wg-0 = {
      paths = [
        "/data/minecraft-wg-0"
      ];
      timerConfig.OnCalendar = "*-*-* 07:14:00";
    };
    hyperberry-data-mc-leedlemon-daily = {
      paths = [
        "/data/minecraft-leedlemon"
      ];
      timerConfig.OnCalendar = "*-*-* 07:16:00";
    };
    hyperberry-data-mc-leedlemon-hourly = {
      paths = [
        "/data/minecraft-leedlemon"
      ];
      pruneOpts = [
        "--keep-last=24"
      ];
      timerConfig.OnCalendar = "*-*-* *:00:00";
    };
    hyperberry-data-teamspeak = {
      paths = [
        "/data/teamspeak"
      ];
      timerConfig.OnCalendar = "*-*-* 07:30:00";
    };
    hyperberry-data-trilium = {
      paths = [
        "/data/trilium-data"
      ];
      timerConfig.OnCalendar = "*-*-* 07:35:00";
    };
  };

  # Define users.
  users.users.dcurgz = {
    isNormalUser = true;
    shell = pkgs.fish;
    group = "dcurgz";
    extraGroups = [
      "wheel"
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
    # ollama
    "d ${ollamaDir} 770 root data -"
  ];

  services = {
    ollama = {
      enable = true;
      user = "ollama";
      group = "ollama";

      home = ollamaDir;
      package = pkgs-ollama.ollama-cuda;

      host = "0.0.0.0"; 
      port = 11434;

      loadModels = [
        "gemma3:27b-it-qat"
        "gemma4:26b" #A4B
        "gemma4:31b"
        "glm-4.7-flash:latest"
        "qwen3.5:27b"
        "qwen3.6:35b"
      ];

      environmentVariables = {
        OLLAMA_FLASH_ATTENTION = "true";
        OLLAMA_CONTEXT_LENGTH = "32768";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
        OLLAMA_KEEP_ALIVE = "10m";
        OLLAMA_MAX_LOADED_MODELS = "4";
        OLLAMA_MAX_QUEUE = "64";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_ORIGINS = "*";
      };
    };
  };

  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    extraGroups = [ "data" ];
  };
  users.groups.ollama = {};

  ##########################################################################################
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # In the vast majority of cases, do not change this version.
  ##########################################################################################
  system.stateVersion = "24.11";
}
