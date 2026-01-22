{
  lib,
  pkgs,
  config,
  ...
}:
with lib;

let
  cfg = config.by.programs.alacritty;
in
{
  options.by.programs.alacritty = {
    enable = mkEnableOption "Enable alacritty terminal emulator.";
    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.alacritty;
      description = "The alacritty package to use.";
    };
  };

  config.home = mkIf (cfg.enable) {
    packages = mkIf (cfg.package != null) [
      cfg.package
    ];

    file = with pkgs; {
      ".config/alacritty/alacritty.toml".source = replaceVars ./alacritty.toml {
        fish = lib.getExe pkgs.fish;
      };
      ".config/alacritty/alacritty-light.toml".source = replaceVars ./alacritty-light.toml {
        fish = lib.getExe pkgs.fish;
      };
    };
  };
}
