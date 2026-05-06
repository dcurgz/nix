{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (globals) FLAKE_ROOT;
  inherit (args.config) flake;
in
{
  flake.nixosConfigurations.blueberry = inputs.self.lib.mkNixOS rec {
      system = "x86_64-linux";
      specialArgs = {
        pkgs = (import inputs.nixpkgs {
          inherit system;
          overlays = [
            (final: prev: import "${FLAKE_ROOT}/pkgs" { inherit inputs final prev; })
          ];
          config.allowUnfree = true;
        });
      };
      modules = with flake.modules;
      [
        (with flake.tags; flake.lib.use [
          flake-default
          nixos-base
          nixos-desktop
        ])
        #generic.git-secrets
        nixos.blueberry
        nixos.blueberry-hardware
        nixos.blueberry-disk
        nixos.authorized-keys
        ({ config, ... }: {
          by.presets.authorized-keys.groups = [
            {
              users = [ "root" "dcurgz" ];
              keys = config.by.keys.ssh.groups.privileged.paths;
            }
          ];
        })
        nixos.nix-daemon
        nixos.ssh
        nixos.gpg
        nixos.git
        nixos.linux-sudo
        nixos.linux-groups
        nixos.packages-core
        nixos.drivers-nvidia
        nixos.drivers-maccel
        nixos.desktop-xdg
        nixos.desktop-audio
        nixos.desktop-wooting
        nixos.home-manager
        {
          by.presets.home-manager.user = "dcurgz";
        }
        home-manager.blueberry
        home-manager.niri
        home-manager.dank-material-shell
        # NixOS modules
        #inputs.nixpkgs.nixosModules.readOnlyPkgs
        #{
        #  nixpkgs.pkgs = pkgs;
        #}
        # 3rd party modules
        inputs.agenix.nixosModules.default
      ];
    };

  flake.modules.nixos.blueberry = flake.lib.nixos.mkAspect (with flake.tags; [ hosts ])
    ({
      lib,
      pkgs,
      config,
      ...
    }:

    let
      keys = config.by.keys;
    in
    {
      # Set your time zone.
      time.timeZone = "Europe/London";
    
      # Select internationalization properties.
      i18n.defaultLocale = "en_GB.UTF-8";
      console = {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
        packages = with pkgs; [ terminus_font ];
        keyMap = "uk";
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
    
      # Enable Fail2Ban for basic intrusion prevention.
      services.fail2ban.enable = true;
    
      services.resolved = {
        enable = true;
      };
    
      # Setup networking.
      networking = {
        hostName = "blueberry";
        enableIPv6 = true;
        nameservers = [
          "1.1.1.1"
          "8.8.8.8"
          "8.8.4.4"
        ];
        firewall = {
          enable = true;
        };
      };
    
      # Define users.
      users.users.dcurgz = {
        isNormalUser = true;
        shell = pkgs.fish;
        group = "dcurgz";
        extraGroups = [
          "wheel"
          "input"
        ];
        home = "/home/dcurgz";
      };
      users.groups.dcurgz = { };
      nix.settings.trusted-users = [ "dcurgz" ];
    
      age.secrets.tailscale-auth-key.file = "${FLAKE_ROOT}/secrets/tailscale/hosts/blueberry.age";
    
      services.tailscale = {
        enable = true; 
        authKeyFile = config.age.secrets.tailscale-auth-key.path;
        useRoutingFeatures = lib.mkDefault "both";
      };
    
      programs.steam.enable = true;
      services.dbus.enable = true;
    
      programs.command-not-found.enable = true;
      programs.fish.enable = true;
    
      ##########################################################################################
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      # In the vast majority of cases, do not change this version.
      ##########################################################################################
      system.stateVersion = "25.05";
    });

  flake.modules.home-manager.blueberry = flake.lib.home-manager.mkAspect []
    ({
      lib,
      ...
    }:

    {
      home.stateVersion = "25.05";
    });
}
