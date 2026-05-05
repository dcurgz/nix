{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.home-manager.alacritty' =
    {
      package ? pkgs.alacritty,
    } @cfg:

    flake.lib.home-manager.mkAspect []
    {
      home = {
        packages = lib.mkIf (cfg.package != null) [
          cfg.package
        ];

        file = with pkgs; {
          ".config/alacritty/alacritty.toml".source = replaceVars ./alacritty.toml {
            fish = lib.getExe pkgs.fish;
          };
        };
      };
    };
}
