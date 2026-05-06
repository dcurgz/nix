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
  flake.modules.home-manager.alacritty' = flake.lib.home-manager.mkAspect []
    ({
      config,
    }:

    let
      cfg = config.by.programs.alacritty;
    in
    {
      options.by.programs.alacritty = {
        package = lib.mkPackageOption pkgs "alacritty" { nullable = true; };
      };

      config.home = {
        packages = lib.mkIf (cfg.package != null) [
          cfg.package
        ];

        file = with pkgs; {
          ".config/alacritty/alacritty.toml".source = replaceVars ./alacritty.toml {
            fish = lib.getExe pkgs.fish;
          };
        };
      };
    });
}
