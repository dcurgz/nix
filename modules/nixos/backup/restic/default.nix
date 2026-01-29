{
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.by.restic;
  resticOptions = {
    initialize = mkOption {
      type = types.bool;
      default = false;
    };
    pruneOpts = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
    };
    timerConfig = {
      OnCalendar = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      Persistent = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
    };
    repository = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };  
    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
    progressFps = mkOption {
      type = types.nullOr types.numbers.nonnegative;
      default = null;
    };
  };
  backupConfig = types.submodule ({ config, name, ... }: {
    options = {
      paths = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "A list of paths for restic to backup.";
      };
    } // resticOptions;
  });
in
{
  options.by.restic.enable = mkEnableOption "Enable dcurgz's restic module.";
  options.by.restic.defaults = mkOption {
    type = types.submodule ({ ... }: { options = resticOptions; });
    default = { };
  };
  options.by.restic.backups = mkOption {
    type = types.attrsOf backupConfig;
    default = { };
  };

  config = mkIf (cfg.enable) {
    services.restic.backups = listToAttrs (mapAttrsToList (name: backup: {
      inherit name;
      value = {
        inherit (backup) paths;
        initialize =
          if backup.initialize != null then
            backup.initialize
          else 
            cfg.defaults.initialize;
        pruneOpts =
          if backup.pruneOpts != null then
            backup.pruneOpts
          else 
            cfg.defaults.pruneOpts;
        timerConfig = {
          OnCalendar =
            if backup.timerConfig.OnCalendar != null then
              backup.timerConfig.OnCalendar
            else 
              cfg.defaults.timerConfig.OnCalendar;
          Persistent =
            if backup.timerConfig.Persistent != null then
              backup.timerConfig.Persistent
            else 
              cfg.defaults.timerConfig.Persistent;
        };
        repository =
          if backup.repository != null then
            backup.repository
          else 
            cfg.defaults.repository;
        passwordFile =
          if backup.passwordFile != null then
            backup.passwordFile
          else 
            cfg.defaults.passwordFile;
        environmentFile =
          if backup.environmentFile != null then
            backup.environmentFile
          else 
            cfg.defaults.environmentFile;
        progressFps =
          if backup.progressFps != null then
            backup.progressFps
          else 
            cfg.defaults.progressFps;
      };
    }) cfg.backups);
  };
}
