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
  flake.metadata.miniberry = {
    type = flake.things.host;
    description = ''
      A Mac Mini M4 that lives under the television. It serves as a build
      server for Darwin and aarch64-linux. Occasionally, it also doubles as a
      "budget" Amazon fire stick. Hey, I got it on a good deal.
    '';
    attributes = {
      uplinks.tailscale0.ipAddress = "100.64.*.*";
    };
  };

  flake.darwinConfigurations.miniberry = inputs.self.lib.mkDarwin rec {
    system = "aarch64-darwin";
    specialArgs = {
      pkgs = prebuiltPackages.${system};
    };
    modules = with flake.modules; [
      (with flake.tags; flake.lib.use [
        flake-default
        darwin-base
      ])
      darwin.miniberry
      darwin.miniberry-hardware
      darwin.authorized-keys
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
      # Declarative VMs
      darwin.vm-mb-build-aarch64
      # Home-manager
      darwin.home-manager
      {
        by.presets.home-manager.user = "dcurgz";
      }
      #home-manager.miniberry
      home-manager.miniberry-hardware
      home-manager.alacritty
      home-manager.fish
      # 3rd party modules
      inputs.nix-homebrew.darwinModules.nix-homebrew
    ];
  };

  flake.modules.darwin.miniberry = flake.lib.darwin.mkAspect (with flake.tags; [ hosts ])
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
      networking.hostName = "miniberry";

      nix-homebrew = {
        enable = true;
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

      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

      services.tailscale.enable = true;

      environment.shells = [ pkgs.fish ];
      programs.fish.enable = true;

      services.openssh.enable = true;

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

      users.knownUsers = [ "builder" ];

      nix.settings.trusted-users = [ "@admin" "dcurgz" "builder" ];

      system.stateVersion = 6;
    });

  flake.deploy.nodes.miniberry = {
    hostname = "miniberry";
    sshUser = "dcurgz";
    remoteBuild = false;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.aarch64-darwin.activate.darwin flake.darwinConfigurations.miniberry;
    };
  };
}
