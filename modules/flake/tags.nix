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
    hosts = mkTag "hosts";
    flake-default = mkTag "flake-default";
    nixos-base = mkTag "nixos-base";
    nixos-desktop = mkTag "nixos-desktop";
    darwin-base = mkTag "darwin-base";
    darwin-desktop = mkTag "darwin-desktop";
  };
}
