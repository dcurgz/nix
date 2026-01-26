{
  lib,
  ...
}:
with lib;

{
  # fix: Module dw-hdmi not found
  # nixpkgs #154163
  boot.initrd.availableKernelModules = {
    dw-hdmi = mkForce false;
    dw-mipi-dsi = mkForce false;
    rockchipdrm = mkForce false;
    rockchip-rga = mkForce false;
    phy-rockchip-host = mkForce false;
    phy-rockchip-pcie = mkForce false;
    pcie-rockchip-host = mkForce false;
    pwm-sun4i = mkForce false;
    sun4i-drm = mkForce false;
    sun8i-mixer = mkForce false;
  };
}
