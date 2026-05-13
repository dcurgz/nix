{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (args.config.by) keys git-secrets;
in
{
  flake.modules.nixos.nix-daemon = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
    (_args:

    {
      nix = {
        settings = {
          substituters = [
            "https://cache.nixos.org/"
            "https://nix-community.cachix.org"
            "https://cuda-maintainers.cachix.org"
            "https://nixos-raspberrypi.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
            "berry-privileged-20260512:bmoVuDlCjUl3iC3pVOzWz0WGtUlDd27FVwICLyQVUrE="
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
        extraOptions = ''
          builders-use-substitutes = true
        '';
        channel.enable = false;
        optimise = {
          automatic = true;
          dates = [ "02:45" ];
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 5d";
        };
        # I'm worried this is required during certain IFD evaluations, but trying without for now.
        #distributedBuilds = true;
        #buildMachines = [
        #  {
        #    hostName = "miniberry";
        #    sshUser = "builder";
        #    sshKey = "/root/.ssh/id_ed25519";
        #    system = "aarch64-darwin";
        #    maxJobs = 8;
        #  }
        #  {
        #    hostName = "vm-mb-build-aarch64";
        #    sshUser = "root";
        #    sshKey = "/root/.ssh/id_ed25519";
        #    system = "aarch64-linux";
        #    maxJobs = 8;
        #  }
        #];
      };
    });

  flake.modules.darwin.nix-daemon = flake.lib.darwin.mkAspect (with flake.tags; [ darwin-base ])
    (_args:
    
    {
      nix = {
        settings = {
          substituters = [
            "https://cache.nixos.org/"
            "https://nix-community.cachix.org"
            "https://cuda-maintainers.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            "berry-privileged-20260512:bmoVuDlCjUl3iC3pVOzWz0WGtUlDd27FVwICLyQVUrE="
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
        extraOptions = ''
          builders-use-substitutes = true
        '';
        channel.enable = false;
        optimise = {
          automatic = true;
          interval = [{ Hour = 2; Minute = 45; }];
        };
        gc = {
          automatic = true;
          interval = [{ Hour = 3; Minute = 0; Weekday = 7; }];
          options = "--delete-older-than 5d";
        };
      };
    });
}
