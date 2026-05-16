{
  inputs,
  ...
} @args:

let
  inherit (args.config) flake;
in
{
  flake.modules.nixos.tauberry-hardware = flake.lib.nixos.mkAspect []
    ({
      config,
      lib,
      pkgs,
      ...
    }:

    {
      hardware.enableRedistributableFirmware = true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

      boot = {
        kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
        kernelModules = [ ];
        initrd.availableKernelModules = [
          "xhci_pci"
          "usbhid"
          "usb_storage"
        ];
        loader = {
          grub.enable = false;
          generic-extlinux-compatible.enable = true;
        };
      };

      hardware.i2c.enable = true;

      hardware.alsa.enablePersistence = true;
      environment.etc."asound.conf".text = ''
        defaults.pcm.!card 1
        defaults.ctl.!card 1
      '';

      # It's somehow possible to apply this overlay at Nix build time, but I have
      # no idea how. I kept getting FDT_ERR_BADOFFSET, or it had no effect at all.
      systemd.services."boss-dac-overlay" = {
        serviceConfig.Type = "oneshot";
        wantedBy = [ "multi-user.target" ];
        script = ''
          ${pkgs.libraspberrypi}/bin/dtoverlay -d ${config.boot.kernelPackages.kernel}/dtbs/overlays/ allo-boss-dac-pcm512x-audio || echo "already in use"
        '';
      };

      by.host-constants.hardware = {
        interfaces.wifi = "wlan0";
      };
    });
}
