{
  self,
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

  nix = {
    enable = true;
    settings = {
      trusted-users = [
        "@admin"
        "dcurgz"
        "nixremote"
      ];
    };
    extraOptions = ''
      extra-platforms = x86_64-darwin x84_64-linux aarch64-linux
    '';
  };

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # User owning the Homebrew prefix
    user = "dcurgz";

    autoMigrate = true;
  };

  homebrew.enable = true;
  homebrew.onActivation.cleanup = "uninstall";

  homebrew.taps = ["deskflow/homebrew-tap"];
  homebrew.brews = [ ];
  homebrew.casks = [ 
    "deskflow"
  ];

  environment.systemPackages = [ ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.primaryUser = "dcurgz";
  users.users.dcurgz = {
    name = "dcurgz";
    home = "/Users/dcurgz";
  };
  users.users.nixremote = {
    shell = pkgs.bashInteractive;
  };

  services.tailscale.enable = true;

  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;

  services.openssh.enable = true;
  by.configure-ssh = {
    enable = true;
    groups = [
      {
        users = [ "root" "dcurgz" ];
        keys = keys.ssh.groups.privileged;
      }
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
