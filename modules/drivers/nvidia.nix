{
  inputs,
  ...
}:

{
  flake.modules.nixos.drivers-nvidia = 
    {
      lib,
      config,
      ...
    }:

    {
      hardware.graphics.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        # This isn't the open-source driver. It's the open kernel modules, which
        # Nvidia recommends using on newer cards.
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };
}
