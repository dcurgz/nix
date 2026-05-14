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
  flake.nixosConfigurations.hyperberry = builtins.break flake.lib.mkNixOS rec {
    system = "x86_64-linux";
    specialArgs = {
      pkgs = prebuiltPackages.${system};
    };
    modules = with flake.modules; [
      (with flake.tags; flake.lib.use [
        flake-default
        nixos-base
        nixos-privileged
      ])
      nixos.hyperberry
      nixos.hyperberry-hardware
      # Configure wg0 VPN and network bridges for MicroVMs
      nixos.hyperberry-network
      nixos.authorized-keys
      {
        by.presets.authorized-keys = {
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
      }
      nixos.avahi
      nixos.linux-builder
      # Declarative VMs
      nixos.vm-claude
      nixos.vm-immich
      nixos.vm-jellyfin
      nixos.vm-mc-leedlemon-0
      nixos.vm-mc-slime-0
      nixos.vm-openwebui
      nixos.vm-trilium
      nixos.vm-vikunja
      nixos.vx-jupiter
      # Services
      nixos.ollama
      # Home-manager
      nixos.home-manager
      {
        by.presets.home-manager.user = "dcurgz";
      }
      home-manager.hyperberry
      home-manager.hyperberry-hardware
      home-manager.fish
    ];
  };

  flake.modules.nixos.hyperberry = flake.lib.nixos.mkAspect (with flake.tags; [ hosts ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:  

    let
      inherit (config.by) host-constants;
    in
    {
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      boot.loader.efi.canTouchEfiVariables = true;

      time.timeZone = "Europe/London";

      i18n.defaultLocale = "en_GB.UTF-8";
      console = {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
        packages = with pkgs; [ terminus_font ];
        keyMap = "uk";
      };

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

      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "armv7l-linux"
      ];

      security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };

      services.fail2ban.enable = true;

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

      services.resolved = {
        enable = true;
      };

      programs.command-not-found.enable = true;
      programs.fish.enable = true;

      age.secrets = {
        restic-password.file = "${FLAKE_ROOT}/agenix-secrets/agenix/backup/restic-password.age";
        restic-envvars.file = "${FLAKE_ROOT}/agenix-secrets/agenix/backup/restic-envvars.age";
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
      # TODO: WARNING: pruneOpts are currently global
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
      nix.settings.trusted-users = [ "dcurgz" ];

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
    });

  flake.modules.home-manager.hyperberry = flake.lib.home-manager.mkAspect []
  ({
    lib,
    config,
    pkgs,
    ...
  }:

  {
    home.stateVersion = "25.05";
  });

  #flake.deploy.nodes.hyperberry = {
  #  hostname = "hyperberry";
  #  sshUser = "dcurgz";
  #  remoteBuild = false;
  #  profiles.system = {
  #    user = "root";
  #    path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos flake.nixosConfigurations.hyperberry;
  #  };
  #};
}
