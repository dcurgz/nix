{
  self,
  config,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  keys = import "${FLAKE_ROOT}/keys" { };
in
{
  # The platform the configuration will be used on.
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
  system.configurationRevision = self.rev or self.dirtyRev or null;

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
        keys = keys.ssh.groups.privileged;
      }
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
