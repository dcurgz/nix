{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.restic = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
    ({
      lib,
      config,
      ...
    }:

    let
      cfg = config.by.restic;
      resticOptions = {
        initialize = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        pruneOpts = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = null;
        };
        timerConfig = {
          OnCalendar = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          Persistent = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
          };
        };
        repository = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
        };  
        environmentFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
        };
        progressFps = lib.mkOption {
          type = lib.types.nullOr lib.types.numbers.nonnegative;
          default = null;
        };
      };
      backupConfig = lib.types.submodule ({ config, name, ... }: {
        options = {
          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "A list of paths for restic to backup.";
          };
        } // resticOptions;
      });
    in
    {
      options.by.restic.enable = lib.mkEnableOption "Enable dcurgz's restic module.";
      options.by.restic.defaults = lib.mkOption {
        type = lib.types.submodule ({ ... }: { options = resticOptions; });
        default = { };
      };
      options.by.restic.backups = lib.mkOption {
        type = lib.types.attrsOf backupConfig;
        default = { };
      };

      config.services.restic.backups = lib.mkIf (cfg.enable) (lib.listToAttrs (lib.mapAttrsToList (name: backup: {
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
      }) cfg.backups));
    });
  }
