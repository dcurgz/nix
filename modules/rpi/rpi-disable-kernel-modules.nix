{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in
{
  flake.modules.nixos.rpi-disable-kernel-modules = flake.lib.nixos.mkAspect (with flake.tags; [ raspberry-pi ])
    ({
      config,
      lib,
      ...
    }:

    {
      # fix: Module dw-hdmi not found
      # nixpkgs #154163
      boot.initrd.availableKernelModules = {
        dw-hdmi = lib.mkForce false;
        dw-mipi-dsi = lib.mkForce false;
        rockchipdrm = lib.mkForce false;
        rockchip-rga = lib.mkForce false;
        phy-rockchip-host = lib.mkForce false;
        phy-rockchip-pcie = lib.mkForce false;
        pcie-rockchip-host = lib.mkForce false;
        pwm-sun4i = lib.mkForce false;
        sun4i-drm = lib.mkForce false;
        sun8i-mixer = lib.mkForce false;
      };
    });
}
