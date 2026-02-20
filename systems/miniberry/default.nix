{
  self,
  pkgs,
  lib,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  keys = import "${FLAKE_ROOT}/keys" { inherit lib; };
in
{
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # User owning the Homebrew prefix
    user = "dcurgz";

    autoMigrate = true;
  };

  homebrew.enable = true;
  homebrew.onActivation.cleanup = "uninstall";

  homebrew.taps = [
    "deskflow/homebrew-tap"
  ];
  homebrew.brews = [
    "watch"
  ];
  homebrew.casks = [ 
    "deskflow"
  ];

  environment.systemPackages = [ ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  services.tailscale.enable = true;

  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;

  services.openssh.enable = true;
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

  system.primaryUser = "dcurgz";
  users.users.dcurgz = {
    name = "dcurgz";
    home = "/Users/dcurgz";
    uid = 501;
    gid = 20; # staff
  };
  users.users.joy = {
    name = "joy";
    home = "/Users/joy";
    uid = 502;
    gid = 20; # staff
  };
  users.users.builder = {
    uid = 701;
    gid = 701;
    description = "Nix remote builder user";
    shell = pkgs.bashInteractive;
  };
  users.groups.builder.gid = 701;

  # This tells nix-darwin which users are safe to create/delete.
  # Don't add system users to this.
  users.knownUsers = [ "builder" ];

  # Note, trusted-users is effectively root.
  nix.settings.trusted-users = [ "@admin" "dcurgz" "builder" ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
