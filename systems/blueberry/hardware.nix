{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  #boot.kernelPackages = latestKernelPackage;
  #boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;

  boot.loader.systemd-boot.enable = true;
  boot.loader.limine = {
    #enable = true;
    #secureBoot.enable = true;
  };

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "uas" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Expose some constants for the main configuration.
  by.constants.hardware = {
    interfaces.ethernet = "enp14s0";
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
