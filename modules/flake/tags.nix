{
  inputs,
  config,
  ...
}:

let
  inherit (config.flake) lib;
in

with lib;
{
  flake.tags = {
    flake-default  = mkTag "flake-default";

    hosts          = mkTag "hosts";

    nixos-base     = mkTag "nixos-base";
    nixos-desktop  = mkTag "nixos-desktop";
    darwin-base    = mkTag "darwin-base";
    darwin-desktop = mkTag "darwin-desktop";

    hyperberry-vm  = mkTag "hyperberry-vm";
  };
}
