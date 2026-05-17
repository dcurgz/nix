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
    flake-default = mkTag "flake-default";

    hosts = mkTag "hosts";

    nixos-base         = mkTag "nixos-base";
    nixos-desktop      = mkTag "nixos-desktop";
    nixos-workstation  = mkTag "nixos-workstation";
    nixos-privileged   = mkTag "nixos-privileged";
    darwin-base        = mkTag "darwin-base";
    darwin-desktop     = mkTag "darwin-desktop";
    darwin-workstation = mkTag "darwin-workstation";
    darwin-privileged  = mkTag "darwin-privileged";

    raspberry-pi = mkTag "raspberry-pi";
  };
}
