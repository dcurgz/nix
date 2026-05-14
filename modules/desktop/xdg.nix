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

    let
      browser = "firefox.desktop";
    in
    {
      xdg = {
        portal = {
          enable = true;
          config.common = {
            default = [ "gtk" ];
          };
          xdgOpenUsePortal = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
          ];
        };
        mime.defaultApplications = {
          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;
        };
      };
    });

  flake.modules.home-manager.desktop-xdg = flake.lib.home-manager.mkAspect (with flake.tags; [ nixos-desktop ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      home.packages = with pkgs; [
        xdg-utils
      ];
    });
}
