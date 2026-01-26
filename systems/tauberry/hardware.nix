{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ ];
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
