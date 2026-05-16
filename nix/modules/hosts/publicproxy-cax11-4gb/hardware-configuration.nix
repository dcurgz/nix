{
  inputs,
  ...
} @args:

let
  inherit (args.config) flake;
in
{
  flake.modules.nixos.publicproxy-cax11-4gb-hardware = flake.lib.nixos.mkAspect []
    ({
      lib,
      modulesPath,
      ...
    }:

    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    });
}
