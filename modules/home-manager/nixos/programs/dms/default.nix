{
  lib,
  pkgs,
  config,
  ...
}:
with lib;

let
  cfg = config.by.programs.dms;
in
{
  options.by.programs.dms = {
    enable = mkEnableOption "Enable Dank Material shell.";
  };

  config.programs = mkIf (cfg.enable) {
    dankMaterialShell = {
      enable = true;
    };
  };

  config.home = mkIf (cfg.enable) {
    file = {
      ".config/DankMaterialShell/settings.json".source = ./settings.json;
    };
  };
}
