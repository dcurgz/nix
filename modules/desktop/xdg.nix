{
  inputs,
  ...
}:

{
  flake.modules.nixos.desktop-xdg = 
    {
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
    };

  flake.modules.home-manager.desktop-xdg = 
    {
      lib,
      config,
      ...
    }:

    {
      # TODO
    };
}
