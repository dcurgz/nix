# Hardware configuration for piberry (Raspberry Pi)
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ ];

  # Enable redistributable firmware
  hardware.enableRedistributableFirmware = true;

  # Basic Raspberry Pi configuration
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
