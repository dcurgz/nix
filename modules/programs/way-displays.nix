{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.home-manager.way-displays = flake.lib.home-manager.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      home.packages = with pkgs; [
        way-displays
      ];

      home.file = {
        ".config/way-displays/cfg.yaml".source = ./way-displays.yaml;
      };
    });
}
