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
  flake.darwinConfigurations.airberry = inputs.self.lib.mkDarwin {
    system = "aarch64-darwin";
    modules = with flake.modules; [
      generic.flake-default'
      generic.git-secrets'
      darwin.airberry'
      darwin.ssh'
      darwin.git'
      inputs.nix-homebrew.darwinModules.nix-homebrew
      (darwin.home-manager'' {
        user = "dylan";
        modules = [
          home-manager.airberry'
          home-manager.alacritty'
        ];
      })
    ];
  };

  flake.modules.darwin.airberry = 
    {
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
        # games
        "prismlauncher"
        # apps
        "alacritty"
        "zed"
        # services
        "tailscale-app"
        # browser
        "firefox"
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
      by.ssh = {
        enable = true;
        groups = [
          {
            users = [ "root" "dylan" ];
            keys = keys.ssh.groups.privileged.paths;
          }
        ];
      };

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
    };

  flake.modules.home-manager.airberry =
    {
      pkgs,
      ...
    }:

    {
      home.stateVersion = "25.05";
      home.packages = with pkgs; [ libiconv ];
    };
}
