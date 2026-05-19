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
  flake.metadata.airberry = {
    type = flake.things.host;
    description = ''
      My M2 Macbook Air, which serves as my portable workstation. To save
      battery life (though the M-chip's power efficiency is unmatched), it uses
      miniberry to build its `nix-darwin` system configuration.
    '';
    attributes = {
      uplinks.tailscale0.ipAddress = "100.64.*.*";
    };
  };

  flake.darwinConfigurations.airberry = inputs.self.lib.mkDarwin rec {
    system = "aarch64-darwin";
    specialArgs = {
      pkgs = prebuiltPackages.${system};
    };
    modules = with flake.modules; [
      (with flake.tags; flake.lib.use [
        flake-default
        darwin-base
        darwin-workstation
        darwin-desktop
      ])
      darwin.airberry
      darwin.airberry-hardware
      darwin.authorized-keys
      {
        by.presets.authorized-keys = {
          groups = [
            {
              users = [ "root" "dylan" ];
              keys = keys.ssh.groups.privileged.paths;
            }
          ];
        };
      }
      darwin.home-manager
      {
        by.presets.home-manager.user = "dylan";
      }
      home-manager.airberry
      home-manager.airberry-hardware
      home-manager.fish
      home-manager.alacritty
      # 3rd party modules
      inputs.nix-homebrew.darwinModules.nix-homebrew
    ];
  };

  flake.modules.darwin.airberry = flake.lib.darwin.mkAspect (with flake.tags; [ hosts ])
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
      nixpkgs.hostPlatform = "aarch64-darwin";
      networking.hostName = "airberry";

      nix = {
        enable = true;
        settings = {
          trusted-users = [
            "@admin"
            "dylan"
          ];
        };
      };

      nix-homebrew = {
        # Install Homebrew under the default prefix
        enable = true;

        # User owning the Homebrew prefix
        user = "dylan";

        autoMigrate = true;
      };

      homebrew.enable = true;
      homebrew.onActivation.cleanup = "uninstall";

      homebrew.brews = [
        # command-line tools
        "gdb"
        "binutils" # gobjdump
        # software
        "tiger-vnc"
      ];

      homebrew.casks = [
        "alacritty"
        "firefox"
        "prismlauncher"
        "tailscale-app"
        "tidal"
        "zed"
      ];

      environment.systemPackages = with pkgs; [
        nix-output-monitor
      ];

      # Set Git commit hash for darwin-version.
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

      system.primaryUser = "dylan";
      users.users.dylan = {
        name = "dylan";
        home = "/Users/dylan";
      };

      environment.shells = [ pkgs.fish ];
      programs.fish.enable = true;

      services.openssh.enable = true;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
    });

  flake.modules.home-manager.airberry = flake.lib.home-manager.mkAspect []
    ({
      pkgs,
      ...
    }:

    {
      home.stateVersion = "25.05";
      home.packages = with pkgs; [ libiconv ];
    });

  flake.deploy.nodes.airberry = {
    hostname = "airberry";
    sshUser = "dylan";
    remoteBuild = false;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.aarch64-darwin.activate.darwin flake.darwinConfigurations.airberry;
    };
  };
}
