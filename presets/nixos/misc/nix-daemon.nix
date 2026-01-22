{
  config,
  lib,
  pkgs,
  ...
}:

{
  #nixpkgs.config.allowUnfree = true;
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.channel.enable = false;
}
