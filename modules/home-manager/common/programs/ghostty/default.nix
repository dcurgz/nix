{
  lib,
  pkgs,
  config,
  ...
}:
with lib;

let
  cfg = config.by.programs.ghostty;
in
{
  options.by.programs.ghostty = {
    enable = mkEnableOption "Enable ghostty terminal emulator.";
    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.ghostty;
      description = "The ghostty package to use.";
    };
  };

  config = mkIf (cfg.enable) {
    programs.ghostty.enable = true;
    programs.ghostty.package = cfg.package;

    programs.ghostty.enableFishIntegration = true;
    programs.ghostty.settings = {
      font-size = 15;
      font-family = "Maple Mono NF";
      font-style = "Regular";
      command = lib.getExe pkgs.fish;
    };
  };
}
