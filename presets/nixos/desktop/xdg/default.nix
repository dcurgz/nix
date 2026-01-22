{
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
}
