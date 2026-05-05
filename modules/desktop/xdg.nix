{
  inputs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.nixos.desktop-xdg = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-desktop ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      xdg.portal = {
        enable = true;
        config.common = {
          default = [ "gnome" ];
        };
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
      };
    });

  flake.modules.home-manager.desktop-xdg = flake.lib.home-manager.mkAspect (with flake.tags; [ nixos-desktop ])
    ({
      lib,
      config,
      ...
    }:

    {
      # TODO
    });
}
