{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  # blueberry is configured as follows:
  # two distinct 2 TB SSDs are installed, where both have their own ESP
  # partition, and a primary OS partition.
  # (1) NixOS, which has secure boot enabled via a signed UKI image.
  #   - this is managed by Limine (bootloader) specifically for NixOS to manage its generations.
  #   - custom keys are generated and installed into the bootloader via `sbctl`.
  # (2) Windows IoT LTSC edition, with the default ESP partition untouched.
  #   - secure boot works per `sbctl`'s option to install the microsoft platform keys.
  boot.loader.limine = {
    enable = true;
    maxGenerations = 5;
    secureBoot.enable = true;
    # this special entry tells limine to chainboot the ESP partition on the Windows 11 SSD.
    # Note, systemd doesn't support this feature. IIRC grub can do it, but
    # limine has special secure boot support for NixOS.
    extraEntries = ''
      /Windows 11
        protocol: efi
        path: uuid(b40fede0-d20d-4bd4-b1e9-b8aec4ec344b):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
    extraConfig = ''
    timeout: no
    '';
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
