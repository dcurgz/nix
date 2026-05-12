{
  config,
  lib,
  pkgs,
  ...
} @args:

let
  inherit (args.globals) FLAKE_ROOT;
  keys = (import "${FLAKE_ROOT}/keys" { inherit lib; });
in
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
      dates = [ "02:45" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5d";
    };
  };
}
