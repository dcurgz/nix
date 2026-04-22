{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:

{
  options.by.programs.alacritty = lib.mkOption {
    type = lib.types.submodule {
      options = {
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = pkgs.alacritty;
        };
      };
    };
  };

  config.flake.modules.home-manager.alacritty =
    args: let
      config' = args.config;
      cfg = config.by.programs.alacritty;
    in
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
