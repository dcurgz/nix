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
    modules = with inputs.self.flake.modules; [
      generic.flake-default
      generic.git-secrets
      darwin.airberry
      darwin.ssh
      darwin.git
      darwin.home-manager
      home-manager.airberry
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
      keys = config.berry.keys;
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
      by.configure-ssh = {
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
}
